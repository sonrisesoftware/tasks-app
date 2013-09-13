Ubuntu Tasks
============

Ubuntu Tasks is a task management app written for Ubuntu Touch as part of the Ubuntu App Showdown.

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
