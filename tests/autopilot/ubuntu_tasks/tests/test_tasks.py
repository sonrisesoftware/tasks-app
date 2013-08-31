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

"""Tests for the Hello World"""

from autopilot.matchers import Eventually
from textwrap import dedent
from testtools.matchers import Is, Not, Equals
from testtools import skip
import os
import os.path
from ubuntu_tasks.tests import UbuntuTasksTestCase


class TasksPageTests(UbuntuTasksTestCase):
    """Generic tests for the Hello World"""

    def setUp(self):
        if os.path.exists('~/.local/share/Qt Project/QtQmlViewer/tasks-app.db'):
            os.remove('~/.local/share/Qt Project/QtQmlViewer/tasks-app.db')
        super(TasksPageTests, self).setUp()
        
    def test_open_project(self):
        PROJECT_NAME = 'New Project'
        
        projectsPage = self.main_view.get_projects_page()
        self.assertThat(projectsPage.get_projects_count, Eventually(Equals(0)))
        
        projectItem = self._create_new_project(PROJECT_NAME)
        
        tasksPage = self._open_project(projectItem)
        self.assertThat(tasksPage.title, Eventually(Equals(PROJECT_NAME)))
        
    #def test_quick_add_task(self):
        #PROJECT_NAME = 'New Project'
        
        #projectsPage = self.main_view.get_projects_page()
        #self.assertThat(projectsPage.get_projects_count, Eventually(Equals(0)))
        
        #projectItem = self._create_new_project(PROJECT_NAME)
        
        #tasksPage = _open_project(projectItem)
        #quickAddBar = tasksPage.get_quick_add_bar()
        
        
    def _open_project(self, projectItem):
        self.pointing_device.click_object(projectItem)
        self.assertThat(self.main_view.get_tasks_page, Eventually(Not(None)))
        return self.main_view.get_tasks_page()
        
        
    def _create_new_project(self, name):
        projectsPage = self.main_view.get_projects_page()
        count = projectsPage.get_projects_count()
        
        toolbar = self.main_view.open_toolbar()
        toolbar.click_button('newProject')
        self._confirm_dialog(name)
        
        self.assertThat(projectsPage.get_projects_count, Eventually(Equals(count + 1)))
        
        projectItem = projectsPage.get_project_by_index(0)
        self.assertThat(projectItem.get_name, Eventually(Equals(name)))
        return projectItem

    def _do_action_on_project(self, project, action):
        project.open_actions_popover()
        actions_popover = self.main_view.get_project_actions_popover()
        actions_popover.click_button(action)
        self.assertThat(
            self.main_view.get_project_actions_popover,
            Eventually(Equals(None)))

    def _confirm_dialog(self, text=None):
        confirm_dialog = self.main_view.get_confirm_dialog()
        if text:
            confirm_dialog.enter_text(text)
        confirm_dialog.ok()