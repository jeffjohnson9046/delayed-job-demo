APPLICATION_ROOT = "/Users/jjohnson3/dev/ruby/rails/delayed-job-demo"
ENV = "development"

God.watch do |w|
  w.name = "pray"
  w.interval = 15.seconds
  w.start = "/bin/bash -c 'cd #{APPLICATION_ROOT}; /usr/bin/env RAILS_ENV=#{ENV} #{APPLICATION_ROOT}/script/delayed_job start -n 4 > /tmp/delay_job.out'"
  w.stop = "/bin/bash -c 'cd #{APPLICATION_ROOT}; /usr/bin/env RAILS_ENV=#{ENV} #{APPLICATION_ROOT}/script/delayed_job stop'"
  w.log = "#{APPLICATION_ROOT}/log/god_delayed_job.log"
  w.start_grace = 30.seconds
  w.restart_grace = 30.seconds
  w.pid_file = "#{APPLICATION_ROOT}/log/delayed_job.pid"

  w.uid = "jjohnson3"
  #w.gid = "jjohnson3"

  w.behavior(:clean_pid_file)

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
  end

  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = 300.megabytes
      c.times = [3, 5] # 3 out of 5 intervals
    end

    restart.condition(:cpu_usage) do |c|
      c.above = 50.percent
      c.times = 5
    end
  end

# lifecycle
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end