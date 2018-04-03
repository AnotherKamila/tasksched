# tasksched

An opinionated Taskwarrior web UI. Great for scheduling when to do your tasks.

![screenshot](./screenshots/big.png)

Drag & drop tasks into the dates to schedule / re-schedule them (or drag them to the unscheduled part to unschedule).

A pretty "next task" page is included:

![next task page screenshot](./screenshots/nexttask.png)

It displays your next scheduled task, or the most urgent task if none are scheduled.

# Overview

This is meant to run "locally", i.e. it does not attempt to deal with authentication, taskserver, or anything. The app must be able to call the `task` CLI with your setup. Therefore, run it as your user, either locally, or on a server where you have set up task synchronization (make sure to put it behind HTTP auth or something if you allow access from the outside).

It does not use taskserver as AFAIK there is no standardized HTTP API. Instead, the included small server translates HTTP calls to calls to the `task` CLI.

# How to use

Requires `node` and `npm`. Install these using your distro's package manager.

`make run` will install dependencies, build the app and run the server. That's all -- `make run`, open http://localhost:5000/ and enjoy :-)

Make sure that the `task` CLI is set up and ready to use before using this.

## Integration with [Timewarrior](https://taskwarrior.org/docs/timewarrior/)

If you have the [Timewarrior hook](https://taskwarrior.org/docs/timewarrior/taskwarrior.html) installed (~/.task/hooks/on-modify.timewarrior), the Next Task page will show a start/pause button to encourage actually tracking time :-)

## Task links

If a task has the `task_url` attribute set, a clickable icon with that URL will be rendered. This is especially useful if you use something like [Bugwarrior](https://bugwarrior.readthedocs.io/) (together with a hook to add a unified `task_url` attribute instead of `$provider_url).

## Optional: Vagrant

If you want to run this in a Vagrant VM, download the `Vagrantfile` and run `vagrant up`. Then
```
vagrant ssh
su - tasks
task add Stuff
```

Note that running it on your "normal" host, as your normal user, is more convenient and the recommended way. This is useful only if you cannot run it on your machine.

## How to get the best Chrome new tab page ever

point this extension:
https://chrome.google.com/webstore/detail/new-tab-url/njigpponciklokfkoddampoienefegcl/related
to your "Next task page" URL (http://localhost:5000/#next)

# Like Tasksched?

Send a pull request, motivate me, or become a patron!

[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/anotherkamila/songbook-web/issues)
[![Say Thanks!](https://img.shields.io/badge/Say%20Thanks-!-1EAEDB.svg)](https://saythanks.io/to/AnotherKamila)
[![Liberapay patrons](https://img.shields.io/liberapay/patrons/kamila.svg)](https://liberapay.com/kamila/donate)

# Thanks to

- built with [Elm](http://elm-lang.org/)
- background images for the awesome next task page come from [the pretty API by Unsplash](https://source.unsplash.com/)
- obviously, [Taskwarrior](https://taskwarrior.org) is awesome
