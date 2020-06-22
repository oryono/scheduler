import Config

config :scheduler, Scheduler.Repo,
  database: "banking_graph_dev",
  username: "root",
  password: "kenp25",
  hostname: "localhost"

config :scheduler, ecto_repos: [Scheduler.Repo]

config :scheduler,
       Scheduler.Scheduler,
       jobs: [
         # Every month on 25th
         {"* * * * *", {Mix.Tasks.MonthlyCharge, :run, [nil]}}
       ]