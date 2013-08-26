delayed-job-demo
----------------
For my current project, I needed to execute some long-running tasks.  I looked at [delayed_job] [1] and [resque] [2].
After reading through resque's readme, I opted for [delayed_job] [1] (small queue size, only a few jobs per day, too lazy to set up Redis).  Another big decision point was this [Railscast] [3], which talks all about using [delayed_job] [1] in an application.

However, I had a couple other requirements:

1.  Monitor log files produced by the various background tasks and return feedback to the user (via a Rails UI).
2.  Have a handy way to make sure the background worker processes are up.  Also, there should be an easy way to start and stop [delayed_job] [1]'s background workers.

So really, this is a [delayed_job] [1], [god] [6] and [faye] [4] demo.

Satisfying the Requirements
---------------------------
To satisfy the log file monitoring requirement, I considered a couple options:

1.  AJAX:  Have the Rais UI poll the log file at some interval to see if the file had changed.  If so, get the changes and present them in the Rails UI.
2.  Event: Have some event (e.g. a new record is writtent to the log file) raise some event that would push the new data to the Rails UI.

I like the second idea better - it just seems easier.  All I need to do is watch the file I care about and publish a notification when it changes.  That's where [faye] [4] comes in.  I figure I'll use something like [listen] [5] (note - this part hasn't been implemented in the demo) to "watch" the log file I care about, and [faye] [4] to push the changes up to the UI.  There's a handy [Railscast] [7] for [faye] [4] that was really helpful in getting started.  As a matter of fact, this demo app is based largely off the code from the [Railscast] [7], but I had to do it myself (seems that's the only way I can learn sometimes).

To tackle the second requirement (a handy way to watch/manage [delayed_job] [1]'s background workers), I opted to use
[god] [6].  Guess what - there's a [Railscast] [8] about that, too.

Configuration
-------------
There's a fair amount of configuration that goes into setting all this up.  Fortunately, it's pretty simple:

[Rails Root]/faye.ru
====================
This file sets up the [faye] [4] server.  To start up the faye server, run the following command:
```rackup faye.ru -s thin -E production```

Oh yeah - [faye] [4] requires a server that supports asynch functionality.  Thin seems to work pretty well (and it's what was used in some examples and the [Railscast] [7].

[Rails Root]/config/initializers/delayed_job_config.rb
======================================================
This file's pretty simple - it just tells [delayed_job] [1]'s Logger to write to ```[Rails Root]/log/worker.log```.  No biggie.

[Rails Root]/config/dj_demo.god
===============================
This is the guy that sets up [god] [6] to start, stop and keep an eye on [delayed_job] [1]'s background workers.  When trying this on your own, be sure to update the ```APPLICATION_ROOT``` at the top of the file.  I conveniently named the job "pray".  'Cause that's meaningful.

To use [god] [6], use the following commands:

```god config -c config/dj_demo.god```:  Configures [god] [6].  If you don't do this, you'll see this error:  The server is not available (or you do not have permissions to access it).  If you're having trouble w/the [god] [6] config file, you can start it up in the foreground, like so:  ```god config -c config/dj_demo.god -D```.  The output should hopefully point to the issue that's occurring.

```god start pray```:  Starts the "pray" job, which kicks off [delayed_job] [1]'s background workers.  If you're tailing [delayed_job] [1]'s log file, you should see entries that indicate the workers are started.

```god stop pray```:  Stops the "pray" job, which gracefully shuts down [delayed_job] [1]'s background workers.  If you're tailing [delayed_job] [1]'s log file, you should see entries that indicate the workers are stopped.

Setup
-----
1.  Clone the app locally.
2.  Run ```bundle install``` to make sure all the required gems are present.
3.  Run ```rake db:migrate``` to set up the database.
4.  Start up the app:  ```rails s thin```.
5.  Create a new mail campaign.

Running/Observing the App
-------------------------
1.  To start the background workers, run the following commands:
    ```god config -c config/dj_demo.god```
    ```god start pray```
2.  To start up the faye server, run the following:
    ```rackup faye.ru -s thin -E production```
3.  I like to tail the ```log/worker.log``` to watch the background workers operate.
4.  Click on the "deliver" button (the envelope icon) to simulate a long-running process.
5.  Observe an alert that indicates the mailing has been enqueued for delayed_job.
5.  Observe that control comes back to the UI immediately - you can go about making other mailings, etc.
6.  After several seconds (10, to be exact), there should be a flurry of alerts indicating the job is finished, it was successful, and at least one of the log entries from the worker.log file should show up.

[1]: https://github.com/collectiveidea/delayed_job
[2]: https://github.com/defunkt/resque
[3]: http://railscasts.com/episodes/171-delayed-job
[4]: http://faye.jcoglan.com/
[5]: https://github.com/guard/listen
[6]: https://github.com/mojombo/god
[7]: http://railscasts.com/episodes/260-messaging-with-faye
[8]: http://railscasts.com/episodes/130-monitoring-with-god
