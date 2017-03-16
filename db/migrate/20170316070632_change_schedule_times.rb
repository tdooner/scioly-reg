class ChangeScheduleTimes < ActiveRecord::Migration
  # Remove the included time zone in the time fields.
  # If the admin puts in 4:00pm, we should store 16:00 in the database.
  def change
    Schedule.update_all("starttime = starttime - interval '5 hours'")
    Schedule.update_all("endtime = endtime - interval '5 hours'")
  end
end
