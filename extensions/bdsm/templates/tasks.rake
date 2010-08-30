#!/usr/bin/env ruby

module BDSM

  def bdsm(environment,command)
    @servers[environment.to_sym].each do |server|
      `ssh #{server} "bash -l -c 'bdsm #{command}'"`
    end
  end

  module Deploy
    task :deploy do
      bdsm(@environment, :deploy)
    end
    task :rollback do
      bdsm(@environment, :rollback)
    end
  end

  module Unicorn
    namespace :unicorn do
      task :start    do bdsm(@environment, :start)    ; end
      task :stop     do bdsm(@environment, :stop)     ; end
      task :restart  do bdsm(@environment, :restart)  ; end
      task :increase do bdsm(@environment, :increase) ; end
      task :decrease do bdsm(@environment, :decrease) ; end
    end
  end

end

namespace :bdsm do

  @servers = {
    :production => %W(),
    :staging    => %W(),
    :qa         => %W(),
    :ci         => %W()
  }

  namespace :production do

    @environment = :production

    include BDSM::Deploy
    include BDSM::Unicorn

  end

  namespace :staging do
    @environment = :staging

    include BDSM::Deploy
    include BDSM::Unicorn
  end

  namespace :qa do
    @environment = :qa

    include BDSM::Deploy
    include BDSM::Unicorn
  end

  namespace :ci do
    @environment = :ci

    include BDSM::Deploy
    include BDSM::Unicorn
  end

end
