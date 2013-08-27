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

    def get_project_page(self):
        """Return the FolderListPage emulator of the MainView."""
        page = self.select_single(HomePage)
        page.main_view = self
        return page

    def get_confirm_dialog(self):
        dialog = self.select_single(ConfirmDialog)
        if dialog is None:
            dialog = self.select_single(ConfirmDialogWithInput)
        return dialog

class ProjectsPage(toolkit_emulators.UbuntuUIToolkitEmulatorBase):
    
    def get_projects_count():
        return len(self.select_many('Standard'))

class HomePage(toolkit_emulators.UbuntuUIToolkitEmulatorBase):
    
    def get_project_name(self):
        if self.main_view.wideAspect:
            return self.projectName
        else:
            return self.title
