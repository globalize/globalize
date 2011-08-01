namespace :db do
  namespace :globalize do
    desc "Synchronize translated columns with database (create/drop table or add/change/remove column)"
    task :up => :environment do
      Globalize::Utils.init(:up)
    end
    
    desc "Drop all globalize translations tables (but be careful: non-refundable)"
    task :down => :environment do
      Globalize::Utils.init(:down)
    end
  end
end
