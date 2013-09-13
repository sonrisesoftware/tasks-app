Ubuntu Tasks
============

Ubuntu Tasks is a task management app written for Ubuntu Touch as part of the Ubuntu App Showdown.

**Trello Integration Limitations**

Below is a list of limitions in Trello support in Ubuntu Tasks. Expect these to go away in future versions!

 * **Connecting to Trello** - There is a bug in the SDK preventing URLs from being opened on the device. To connect to Trello, open this link on your PC:
 
    <https://trello.com/1/authorize?key=333870c6f8dc97cb6a14e79dfe119675&name=Ubuntu+Tasks&expiration=30days&response_type=token&scope=read,write>
    
    Once you've allowed Ubuntu Tasks to access your Trello account, you will be given a long token. You will need to type this into the Token field in the Trello authentication text field on the device to connect, and then press the Ok button.
 
    In the future, I plan on using Ubuntu's Online Accounts feature to make authentication much easier. However, Trello is not currently an Online Account and there were some issues in adding an Online Account for it.

 * **Multiple Members** - Currently, Trello integration only supports single-user boards. There is no way to assign tasks to other users, and I have not tested it with other users added to a board. I do not know what happens when other users are involved in a board.
 
 * **Checklists** - Checklists show up, but are not editable. I've been unable to figure out how to upload changes to a checklist using the API. Also, due to the way my backend is written, only the first Checklist is visible.
 
 * **User Icons** - Currently, the user icon for assigned tasks is simply a generic user icon.
 
 * **Lists** - Currently, there is no way to view individual lists. The visible tasks are all the tasks from lists other than Done. Completing a task moves it to Done. Assigning a user to a card moves it to the Doing list. This is the best workflow I've been able to come up with based on how I use Trello. If you can think of a better way, please file a bug.
 
 * **Labels** - Labels currently are uneditable, both editing the actual label name and changing the labels on a given card. I tried making labels assigned to a card editable, but the API didn't do anything.

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
