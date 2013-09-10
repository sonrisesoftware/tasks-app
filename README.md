Ubuntu Tasks
============

### Installation ###

**Dependencies:**

 * Ubuntu SDK
 * U1db - qtdeclarative5-u1db1.0
 * Ubuntu UI Extras (see below)

To install Ubuntu UI Extras, you will need [Code Units](https://github.com/iBeliever/code-units), a small utility to download bits of code.

Once Code Units is installed, you can get the Ubuntu UI Extras by running

    code install ubuntu-ui-extras
    code use ubuntu-ui-extras

To run Ubuntu Tasks, simply open in Qt Creator/Ubuntu SDK, and click the run button!

NOTE: To help the packaging process, I have an automaticed script that does several things, including updating version numbers. Because of this, the version number is not included in either `manifest.json` or the About page.

To package the app, run

../clickpkg <version number, such as 1.2.3>

This will create a package in ../releases/ubuntu-tasks/

### App Showdown Progress ###

Day 1 - 8/7/2013
 * Showdown announced
 * Project selected
 * Initial ideas and code

Day 2 - 8/8/2013
 * Adding tasks
 * Deleting tasks
 * Assigning a due date
 * Marking a task as completed
 * Editing a task
 * Deleted a task
 * Storage of tasks and settings in U1db
 * Color coded labels
 * Hiding of completed tasks

Day 3 - 8/9/2013
 * Improved editing of tasks
 * Initial custom date picker
 * Concepts for checklists
 * Completing a task from the task list

Day 4 - 8/10/2013
 * Quick add task field in tasks list
 * Multiple lists (categories)

Day 5 - 8/11/2013
 * Initial Suru theme (from Calculator app)

Day 6 - 8/12/2013
 * Animation on completing a task in the list
 * Due date hidden if not set
 * Better category managment
 * Categories independant of tasks
 * Add categories
 * Delete categories
 * Rename categories
 * Initial statistics view

Day 7 - 8/13/2013
 * Converted Add Task sheet into a page
 * Converted Statistics sheet into a page

Day 9 - 8/15/2013
 * Redesigned task view and create pages

Day 10 - 8/16/2013
 * Added adaptive layout

Day 12 - 8/18/2013
 * Began new backend

Day 13 - 8/19/2013
 * Completed new backend
 * Repeating tasks
 * Checklists

**Released version 0.1**

Day 14 - 8/20/2013
 * Updated to use the `ubuntu-ui-extras` code unit
 * New icon!
 * Statistics
 * Better removal of checklist items
 * Upcoming view shows tasks due this week
 * Toolbar locked and opened in wide mode

Day 15 - 8/21/2013
 * Improved home page toolbar buttons
 * Move task options into sidebar in wide aspect mode
 * Added apply button to editable labels

Day 17 - 8/23/2013
 * Began Trello backend

Day 20 - 8/26/2013
 * Redesigned checklists
 * Continued work on Trello backend

Day 27 - 9/2/2013
 * Rewritten backend
 * UI for Trello lists
 * Read-only Trello backend
 * Ability to create Trello projects

**Released version 0.2**

Day 28 - 9/3/2013
 * Worked on fixing various bugs
 * Improved the About page

Day 29 - 9/4/2013
 * Worked on fixing various bugs
 * Tags
 * Better about page
 * Search page
 * Fixed repeating tasks

**Released version 0.2.3**

Day 30 - 9/5/2013
 * Fixed completion date
 * Added uncategorized feature

**Released version 0.3**

Day 30 - 9/5/2013
 * Fixed label font size in tasks list
 * Added editing of some Trello card fields

**Released version 0.3.1**

Day 31 - 9/6/2013
 * Improved performance on startup
 * Fixed Trello field locking
 * Added support for deleting tasks in Trello
 * Added support for adding tasks to a Trello board
 * Added support for renaming/archiving Trello projects
 * Fixed Trello refresh

**Released version 0.4**

Day 32 - 9/7/2013
 * Only display the Trello progress bar on first load or user action (not startup sync)
 * Fixed icon in About page
 * Fixed deleted tasks from reappearing on Trello syncing
 * Added description UI and merged project actions into Project popover

**Released version 0.4.1**

Day 34 - 9/9/2013
 * Added inline editing for project description
