# Script that runs the supplied file in 3dsMax.

from __future__ import unicode_literals

import os, sys, re
import winapi

DEFAULT_DOCS_VERSION = "2019"

# Holds the current 3ds Max window object that we send commands to.
# It is filled automatically when sending the first command.
mainwindow = None

# Used to preselect the last 3ds Max window in the quick panel.
last_index = 0

TITLE_IDENTIFIER = "Autodesk 3ds Max"
TEMPFILE = os.path.join(
    os.path.dirname(os.path.dirname(os.path.realpath(__file__))),
    "send_to_3ds_max_temp.ms")


def _is_maxscriptfile(filepath):
    """Return if the file uses one of the MAXScript file extensions."""
    name, ext = os.path.splitext(filepath)
    return ext in (".ms", ".mcr", ".mse", ".mzp")


def _is_pythonfile(filepath):
    """Return if the file uses a Python file extension."""
    name, ext = os.path.splitext(filepath)
    return ext in (".py",)


def _save_to_tempfile(text):
    """Store code in a temporary maxscript file."""
    with open(TEMPFILE, "w") as tempfile:
        tempfile.write(text)


def _send_cmd_to_max(cmd):
    """Try to find the 3ds Max window by title and the mini
    macrorecorder by class.

    Sends a string command and a return-key buttonstroke to it to
    evaluate the command.

    """
    global mainwindow

    if mainwindow is None:
        mainwindow = winapi.Window.find_window(TITLE_IDENTIFIER)

    if mainwindow is None:
        print("Could not find a max instance.")
        return

    try:
        mainwindow.find_child(text=None, cls="MXS_Scintilla")
    except OSError:
        # Window handle is invalid, 3ds Max has probably been closed.
        # Call this function again and try to find one automatically.
        mainwindow = None
        _send_cmd_to_max(cmd)
        return

    minimacrorecorder = mainwindow.find_child(text=None, cls="MXS_Scintilla")
    # If the mini macrorecorder was not found, there is still a chance
    # we are targetting an ancient Max version (e.g. 9) where the
    # listener was not Scintilla based, but instead a rich edit box.
    if minimacrorecorder is None:
        statuspanel = mainwindow.find_child(text=None, cls="StatusPanel")
        if statuspanel is None:
            print("Could not find MAXScript Macro Recorder")
            return
        minimacrorecorder = statuspanel.find_child(text=None, cls="RICHEDIT")
        # Verbatim strings (the @ at sign) are also not yet supported.
        cmd = cmd.replace("@", "")
        cmd = cmd.replace("\\", "\\\\")

    if minimacrorecorder is None:
        print("Could not find MAXScript Macro Recorder")
        return

    print('Sent to 3dsMax: {cmd}'.format(**locals())[:-1], end='')  # Cut ';'
    cmd = cmd.encode("utf-8")  # Needed for ST3!
    minimacrorecorder.send(winapi.WM_SETTEXT, 0, cmd)
    minimacrorecorder.send(winapi.WM_CHAR, winapi.VK_RETURN, 0)
    minimacrorecorder = None


def _get_max_version():
    """Try to determine the version of 3ds Max we are connected to."""
    global mainwindow
    if mainwindow is None:
        mainwindow = winapi.Window.find_window(
            TITLE_IDENTIFIER)

    # Default to 2018 help, this has the most updated docs and will
    # filter to Maxscript results.
    max_version = DEFAULT_DOCS_VERSION

    if mainwindow is not None:
        window_text = mainwindow.get_text()
        matches = re.findall(r"(?:Max )(2\d{3})", window_text)
        if matches:
            last_match = matches[-1]
            max_version = last_match

    return max_version


class SendFileToMaxCommand:
    """Send the current file by using 'fileIn <file>'."""

    def run(self, currentfile):
        if not os.path.exists(currentfile):
            print("file does not exist.")
            return

        is_mxs = _is_maxscriptfile(currentfile)
        is_python = _is_pythonfile(currentfile)

        if is_mxs:
            cmd = 'fileIn @"{0}"\r\n'.format(currentfile)
            _send_cmd_to_max(cmd)
        elif is_python:
            cmd = 'python.executeFile @"{0}"\r\n'.format(currentfile)
            _send_cmd_to_max(cmd)
        else:
            print("no supported file")

if __name__ == "__main__":
    # execute only if run as a script
    filepath = os.path.join(os.path.abspath(sys.argv[1]))
    runner = SendFileToMaxCommand()
    runner.run(filepath)

