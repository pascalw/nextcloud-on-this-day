require "dotenv"
Dotenv.load

require "./indexer/main"
Indexer::Main.run
