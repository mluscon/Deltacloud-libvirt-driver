require 'rubygems'
require 'resque'
require 'resque/status'
require 'fileutils'

class Copy
  @queue = :copy
  def self.perform(from, to)
    Fileutils.cp( from, to )
  end
end

job_id = Resque.enqueue Copy, ["/home/mluscon/test.img" , "/home/mluscon/copy_test.img"]
puts Resque::Status.get(job_id)

