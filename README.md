What?
=====

Go With The Flow is a Unix CLI orientated todo/task tracker.

Each todo item has a short description, a optional long description,
a status and a work log.

It supports different projects with unique lists of tasks and can track
time worked per task either through specifically supplying time worked
or via sub-shells.

gwtf is written using the excellent gli gem so it behaves a lot like
the git command line.

Tasks are stored in simple JSON files and each time you save or edit a
task a backup of the previous state is made.  There is a simple Ruby
API for interacting with the tasks list in your own code.

Basic Usage?
============

By default tasks are written to ~/.gwtf.d/ directory, sub directories
per project exist under this directory.

I alias gwtf to the _t_ command using my shell alias facilities.

Adding a task
-------------

    % gwtf new this is a test task
    Created a new project default in /home/rip/.gwtf.d/default
       29                 this is a test task

You can pass an optional _--edit_ or _-e_ flag to the new command that
will start your editor configured using EDITOR to edit the long form
description of a task

When creating an item you can pass the same arguments as to the remind
command which will schedule an emailed reminder.  See the _Reminders_
section below for details.

    % gwtf new this is a test --remind="now + 1 week" --done --ifopen
    Creating reminder at job for item 30: job 46 at 2012-03-13 20:09
       30                 this is a test

The above command will send an email alert 1 week from now if the item has
not already been completed and mark the item as done after sending the alert,
more details in the Remind section

You can set a due date for a specific task, tasks with due date will be
colorized in your list output - yellow for items due today or morrow and
red for overdue items.  Due dates are shown in the list output etc

     % gwtf new --due="2012/04/07" this is a test

     Project test items: 1 / 11

        77     2012/04/07 test

Logging work for a task
-----------------------

Each task has a work log that you can write to:

    % gwtf log 0 "Create a README file" -m 20
    Logged 'Create a README file' against item 0 for 20 minutes 0 seconds

Viewing a task
--------------

    % gwtf show 0
             ID: 0
        Subject: this is a test task
         Status: open
    Time Worked: 20 minutes 0 seconds
        Created: 03/10/12 21:23

    Work Log:
                 03/10/12 21:25 Create a README file

Completing a task
-----------------

    % gwtf done 0
    Marked item 0 as done

List of tasks
-------------

By default completed tasks are not shown:

    % gwtf list
        1 D   2012-03-10 this is another test task to demonstrate

    Items: 1 / 2

But you can list all tasks:

    % gwtf ls -a
        0 C              this is a test task
        1 D   2012-03-10 this is another test task to demonstrate

    Items: 1 / 2

The _C_ and _D_ flags indicate that item 0 is Closed while item 1 has a
full Description that you can view with the show command. There are also
a _L_ flag that indicate an item has work log items and _O_ that means it's
overdue.

There's a short summary mode ideal for using in your login scripts:

    % gwtf ls --summary
    Items in all projects:

       gwtf: open:   5: closed   4: total:   9
       test: open:   0: closed   4: total:   4

Editing a task
--------------

You can edit a task subject right on the command line:

    % gwtf edit 1 /another/the first
    1 (open): this is the first test task to demonstrate

If you leave off the replacement logic it will edit the item using your
editor as defined in EDITOR

Logging work done interactively?
--------------------------------

If you're working on some code you can track the time spent working
on it using gwtf:

    % gwtf new add a readme file
    Item 3 saved

    % gwtf shell 3
    Starting work on item 3, exit to record the action and time
    %

This shell will have GWTF_ITEM, GWTF_PROJECT and GWTF_SUBJECT environment
variables set for use in your prompt or shell script.

Now you can work in this shell and once you're done simply exit it:

    % exit
    Optional description for work log (start with done! to close):: First stab at writing a readme file
    Recorded 91.6566 seconds of work against item 3

Your log will be visible in the show command along with a total work time
for the task:

             ID: 3
        Subject: add a readme file
         Status: open
    Time Worked: 1 minutes 32 seconds
        Created: 03/10/12 21:41

    Work Log:
                 03/10/12 21:43 First stab at writing a readme file (1 minutes 32 seconds)

You can pass *--pre* and *--post* flags to the shell command that will run shell commands
before and after the subshell, this is good for tweaking your tmux status bar while working
on tasks for example

Projects?
=========

There is a very simplistic project model that simply creates a new
set of tasks in a different sub-directory off the top directory.

    % gwtf --project=acme new this is a different project
    Created a new project acme in /home/rip/.gwtf.d/acme
    Item 2 saved

Note that item numbers a unique for the entire installation to avoid
confusion due to overlapping item numbers.

Reminders
=========

To facilitate reminders by email we use your at system and the normal mail command present
in most Unix systems.  To schedule a reminder for an item you can use anything your at will
accept as a time specification:

    % gwtf remind 3 now + 1 week

This will create an at job that will in a week call gwtf asking it to send an email immediately.
The email will be sent using the normal mail command to your unix user.  You should have a
.forward file in place to send mail to where you need it otherwise you can invoke the remind
command with --recipient

If all you really want is to schedule a reminder for some future task you pass --done to the
remind command which will then mark your item done after reminding you about it.  A note of
the action will be added to the work log.

If you want to set a reminder for a future time but only if the item is still open by that time
pass the --ifopen flag when creating the reminder

To cancel reminders or see which ones you have scheduled use your normal at commands like atq
and atrm

You can send notifications to iPhone, iPads and Macs using Boxcar, see the BOXCAR.md file in
the git repository for details

Adding a reminder only task
---------------------------

We support reminders by abusing the projects feature creating a project specific to reminders.

To schedule a simple reminder for something do:

    % gwtf remind --at="now +1 hour" do something
    Creating reminder at job for item 84: job 66 at 2012-04-10 15:11
        84                do something

This creates an item in the _reminders_ project. It's really just a shortcut to the following
command:

    % gwtf -p reminders new --remind="now +1 hour" --done --ifopen do something

You can easily cancel a reminder:

   % gwtf -p reminders ls
   Project reminders items: 1 / 3

       84                do something

   % gwtf -p reminders done 84
       84 C              test reminder

The _reminders_ project is one that is ignored by the _list --summary_ and _list --overview_
commands so they do not show up as tasks, but other than that they are just normal items that
you can manage same as any other task.

These reminders might get recurring features in future

Daily Summary Emails
====================

There is no built in mailer for daily summary mails but they are very easy to achieve with cron
and the mail command:

    @daily gwtf ls --overview | mail -s "Daily Summary of Tasks" you@your.com

Put that in your users crontab with _crontab -e_ and you should get daily mails listing all
outstanding tasks for all projects.

Default Project, Data Dir or Email Recipient?
=============================================

You can adjust the default data dir and project which would then be saved
into the config file - _~/.gwtf_:

    % gwtf --help
    Global Options:
        --data, -d data_dir   - Path to storage directory (default: /home/rip/.gwtf.d)
        --help                - Show this message
        --project, -p project - Active project (default: default)

Now change the defaults:

    % gwtf --data=/tmp/gwtf -p acme initconfig
    Created a new project acme in /tmp/gwtf/acme

And confirm the change is active:

    % gwtf --help
    Global Options:
        --data, -d data_dir   - Path to storage directory (default: /tmp/gwtf)
        --help                - Show this message
        --project, -p project - Active project (default: acme)

You can reset to factory defaults by just removing the _~/.gwtf_ file or by changing
the defaults again.

You can also set defaults for options to individual commands, after running initconfig
your _~/.gwtf_ file will have empty space for each command.  If you wanted to specify a
default email address for reminders simply edit that file and put in:

    commands:
      :remind:
        :recipient: rip@devco.net

Now _gwtf help remind_ will show it's defaulting to the new email address so you do not
have to keep typing the --recipient on every invocation.

Contact?
========

R.I.Pienaar / rip@devco.net / @ripienaar / http://devco.net/
