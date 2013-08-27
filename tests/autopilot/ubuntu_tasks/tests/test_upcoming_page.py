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
from ubuntu_tasks.tests import UbuntuTasksTestCase


class MainTests(UbuntuTasksTestCase):
    """Generic tests for the Hello World"""

    def setUp(self):
        super(MainTests, self).setUp()

    def test_mainView_shows(self):
        """Must be able to select the mainview."""

        self.assertThat(self.main_view.visible,Eventually(Equals(True)))

    def test_upcoming_tasks(self):
        """Check that the first view is upcoming tasks"""
        projectPage = self.main_view.get_project_page()
        self.assertThat(projectPage.get_project_name, Eventually(Equals("Upcoming")))
        
    def test_projects_page(self):
        if self.main_view.wideAspect:
            projectPage = self.main_view.get_project_page()
            self.assertThat(projectPage.title, Eventually(Equals("Tasks")))
