class MakeTimeslotTimesTimes < ActiveRecord::Migration
  def change
    change_column :timeslots, :begins, :time
    change_column :timeslots, :ends, :time

    Timeslot.all.includes(schedule: { tournament: :school }).find_each do |timeslot|
      zone = timeslot.schedule.try(:tournament).try(:school).try(:time_zone)
      zone = zone.presence || 'Eastern Time (US & Canada)'

      Time.use_zone(zone) do
        new_begins = timeslot.begins + Time.zone.utc_offset
        new_ends = timeslot.ends + Time.zone.utc_offset

        timeslot.update_attributes(
          begins: new_begins,
          ends: new_ends,
        )
      end
    end
  end
end
