class BroadcastSeeder

  def run
    broadcasts = parse_broadcasts
    monday = 1.year.ago.beginning_of_week.to_date.to_time
    Show.transaction do
      while monday < (Date.today - 60)
        create_weekly_broadcasts(broadcasts, monday)
        monday += 7.days
      end
    end
  end

  private

  def create_weekly_broadcasts(broadcasts, monday)
    broadcasts.each do |day, start_offset, finish_offset, name|
      show = Show.where(name: name).first_or_create!
      show.broadcasts.create!(label: name,
                              started_at: monday + start_offset,
                              finished_at: monday + finish_offset)
    end
  end

  def parse_broadcasts
    load_broadcasts.collect do |day, start, finish, name|
      start_offset = make_time(day, start)
      finish_offset = make_time(day, finish)
      finish_offset += 1.day if finish_offset < start_offset
      [day, start_offset, finish_offset, name]
    end
  end

  def load_broadcasts
    input = File.read('db/seeds/broadcasts.txt')
    input.split("\n").reject(&:blank?).map { |line| line.split("\t") }
  end
  
  def make_time(day, time)
    hour, min = time.split(':')
    day.to_i.days + hour.to_i.hours + min.to_i.minutes
  end

end
