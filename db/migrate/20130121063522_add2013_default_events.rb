EVENTS = {
  'B' => ['Anatomy',
    'Disease Detectives',
    'Forestry',
    'Heredity',
    'Water Quality',
    'Dynamic Planet',
    'Meteorology',
    'Reach for the Stars',
    'Road Scholar',
    'Rocks and Minerals',
    'Physics',
    'Keep the Heat',
    'Shock Value',
    'Sounds of Music',
    'Chemistry',
    'Crime Busters',
    'Food Science',
    'Boomilever',
    'Helicopters',
    'Mission Possible',
    'Mousetrap',
    'Experimental Design',
    'Metric Mastery',
    'Rotor Egg Drop',
    'Write It Do It'],
  'C' => ['Anatomy & Physiology',
    'Designer Genes',
    'Disease Detectives',
    'Forestry',
    'Water Quality',
    'Astronomy',
    'Dynamic Planet',
    'Remote Sensing',
    'Rocks and Minerals',
    'Physics',
    'Circuit Lab',
    'MagLev',
    'Thermodynamics',
    'Chemistry',
    'Chem Lab',
    'Forensics',
    'Materials Science',
    'Boomilever',
    'Elastic Launched Glider',
    'Gravity Vehicle',
    'Robot Arm',
    'Experimental Design',
    'Fermi Questions',
    'Tech. Problem Solving',
    'Write It Do It'],
}
YEAR = 2013

class Add2013DefaultEvents < ActiveRecord::Migration
  def up
    EVENTS.each do |division, event_list|
      event_list.each do |event|
        DefaultEvent.for_year(YEAR).create(:division => division, :name => event)
      end
    end
  end

  def down
    DefaultEvent.for_year(YEAR).destroy_all
  end
end
