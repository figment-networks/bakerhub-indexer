require 'pathname'

class TaskLock
  RETRIES = 3
  WAIT_TIME = 5.seconds

  LOCKFILE_BASE = Rails.root.join('tmp', 'pids')
  LOCKFILES = {
    sync: 'task-lock--sync.lock',
    sync_governance: 'task-lock--sync_governance.lock'
  }

  class << self

    def with_lock!( name, &block )
      return unless acquire_lock!( name )
      begin
        block.call()
      ensure
        unlock!( name )
      end
    end

    def unlock!( name=nil )
      lockfiles = name ? [LOCKFILES[name]] : LOCKFILES.values
      lockfiles.map! { |path| File.join( LOCKFILE_BASE, path ) }
      FileUtils.rm_f lockfiles
    end

    private

    def acquire_lock!( name )
      FileUtils.mkdir_p LOCKFILE_BASE
      lockfiles = name ? [LOCKFILES[name]] : LOCKFILES.values
      lockfiles.map! { |path| File.join( LOCKFILE_BASE, path ) }

      already_locked = !ENV['FORCE_LOCK'] && lockfiles.any? { |f| File.exists?(f) }

      tries = RETRIES
      if already_locked
        tries -= 1 while tries > 0 && lockfiles.any? { |f| File.exists?(f) }
      end
      if tries == 0
        lockfile_location = File.join(
          Pathname.new( LOCKFILE_BASE ).relative_path_from( Rails.root ).to_s
        )
        puts <<~MSG
          Bailing out, sync already running.
          Override: delete lockfiles in #{lockfile_location} or specify FORCE_LOCK=1:
          #{lockfiles.map { |f| "\t"+File.basename(f) }.join( "\n" ) }
        MSG
        exit 0
      else
        FileUtils.touch lockfiles
        return true
      end
    end
  end
end
