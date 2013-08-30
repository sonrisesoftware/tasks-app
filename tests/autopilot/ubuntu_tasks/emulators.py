# -*- Mode: Python; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Whatsoever ye do in word or deed, do all in the name of the
# Lord Jesus, giving thanks to God and the Father by him.
# - Colossians 3:17
#
# Ubuntu Tasks - A task management system for Ubuntu Touch
# Copyright (C) 2013 Michael Spencer <spencers1993@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

import re
import time

from autopilot import input

from ubuntuuitoolkit import emulators as toolkit_emulators


class MainView(toolkit_emulators.MainView):
    """Ubuntu Tasks MainView Autopilot emulator."""

    def get_projects_page(self):
        page = self.select_single(ProjectsPage)
        page.main_view = self
        return page

    def get_confirm_dialog(self):
        dialog = self.select_single(ConfirmDialog)
        if dialog is None:
            dialog = self.select_single(InputDialog)
        return dialog
        
    def get_project_actions_popover(self):
        """Return the ActionSelectionPopover emulator of the file actions."""
        return self.select_single(
            ActionSelectionPopover, objectName='projectActionsPopover')

class ProjectsPage(toolkit_emulators.UbuntuUIToolkitEmulatorBase):
    
    def get_projects_count(self):
        return len(self.select_many(ProjectListItem))
        
    def get_project_by_index(self, index):
        item = self.select_many(ProjectListItem)[index]
        return item

class HomePage(toolkit_emulators.UbuntuUIToolkitEmulatorBase):
    
    def get_project_name(self):
        if self.main_view.wideAspect:
            return self.projectName
        else:
            return self.title        
    

class ProjectListItem(toolkit_emulators.UbuntuUIToolkitEmulatorBase):
    def __init__(self, *args):
        super(ProjectListItem, self).__init__(*args)
        self.pointing_device = toolkit_emulators.get_pointing_device()
    
    def get_name(self):
        return self.text
        
    def open_actions_popover(self):
        self.pointing_device.move_to_object(self)
        self.pointing_device.press()
        time.sleep(1)
        self.pointing_device.release()
        
class ConfirmDialog(toolkit_emulators.UbuntuUIToolkitEmulatorBase):
    """ConfirmDialog Autopilot emulator."""

    def __init__(self, *args):
        super(ConfirmDialog, self).__init__(*args)
        self.pointing_device = toolkit_emulators.get_pointing_device()

    def ok(self):
        okButton = self.select_single('Button', objectName='okButton')
        self.pointing_device.click_object(okButton)

    def cancel(self):
        cancel_button = self.select_single('Button', objectName='cancelButton')
        self.pointing_device.click_object(cancel_button)

class InputDialog(ConfirmDialog):

    def __init__(self, *args):
        super(InputDialog, self).__init__(*args)
        self.keyboard = input.Keyboard.create()

    def enter_text(self, text, clear=True):
        if clear:
            self.clear_text()
        text_field = self._select_text_field()
        self.pointing_device.click_object(text_field)
        self.keyboard.type(text)
        text_field.text.wait_for(text)

    def clear_text(self):
        text_field = self._select_text_field()
        # XXX The clear button doesn't have an objectName. Reported on
        # https://bugs.launchpad.net/ubuntu-ui-toolkit/+bug/1205208
        # --elopio - 2013-07-25
        clear_button = text_field.select_single('AbstractButton')
        # XXX for some reason, we need to click the button twice.
        # More investigation is needed. --elopio - 2013-07-25
        self.pointing_device.click_object(clear_button)
        self.pointing_device.click_object(clear_button)
        text_field.text.wait_for('')

    def _select_text_field(self):
        return self.select_single('TextField', objectName='inputField')

class ActionSelectionPopover(toolkit_emulators.UbuntuUIToolkitEmulatorBase):
    """ActionSelectionPopover Autopilot emulator."""
    # TODO Move this to the ubuntu-ui-toolkit. Reported on
    # https://bugs.launchpad.net/ubuntu-ui-toolkit/+bug/1205205
    # --elopio - 2013-07-25

    def __init__(self, *args):
        super(ActionSelectionPopover, self).__init__(*args)
        self.pointing_device = toolkit_emulators.get_pointing_device()

    def click_button(self, text):
        """Click a button on the popover.

        XXX We are receiving the text because there's no way to set the
        objectName on the action. This is reported at
        https://bugs.launchpad.net/ubuntu-ui-toolkit/+bug/1205144
        --elopio - 2013-07-25

        :parameter text: The text of the button.

        """
        button = self._get_button(text)
        if button is None:
            raise ValueError(
                'Button with text "{0}" not found.'.format(text))
        self.pointing_device.click_object(button)

    def _get_button(self, text):
        buttons = self.select_many('Empty')
        for button in buttons:
            if button.text == text:
                return button
                
