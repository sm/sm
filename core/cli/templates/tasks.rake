#!/usr/bin/env ruby

module SM

  def sm(environment,command)
    @servers[environment.to_sym].each do |server|
      %x{ssh #{server} "bash -l -c 'sm #{command}'"}
    end
  end

  module Deploy
    task :deploy do
      sm(@environment, :deploy)
    end
    task :rollback do
      sm(@environment, :rollback)
    end
  end

  # TODO: allow dynamic action specification.
  module Unicorn
    namespace :unicorn do
      task :start    do sm(@environment, :start)    ; end
      task :stop     do sm(@environment, :stop)     ; end
      task :restart  do sm(@environment, :restart)  ; end
      task :increase do sm(@environment, :increase) ; end
      task :decrease do sm(@environment, :decrease) ; end
    end
  end

end

namespace :cli do

  @servers = {
    :production => %W(),
    :staging    => %W(),
    :qa         => %W(),
    :ci         => %W()
  }

  namespace :production do

    @environment = :production

    include SM::Deploy
    include SM::Unicorn

  end

  namespace :staging do
    @environment = :staging

    include SM::Deploy
    include SM::Unicorn
  end

  namespace :qa do
    @environment = :qa

    include SM::Deploy
    include SM::Unicorn
  end

  namespace :ci do
    @environment = :ci

    include SM::Deploy
    include SM::Unicorn
  end

end
