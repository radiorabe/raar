# frozen_string_literal: true

# == Schema Information
#
# Table name: cc_show_instances
#
#  id                :integer          not null, primary key
#  starts            :datetime         not null
#  ends              :datetime         not null
#  show_id           :integer          not null
#  record            :integer          default(0)
#  rebroadcast       :integer          default(0)
#  instance_id       :integer
#  file_id           :integer
#  time_filled       :integer
#  created           :datetime         not null
#  last_scheduled    :datetime
#  modified_instance :boolean          default(FALSE), not null
#

module Airtime
  # rubocop:disable Layout/LineLength
  # <column name="id" phpName="DbId" type="INTEGER" primaryKey="true" autoIncrement="true" required="true"/>
  # <column name="description" phpName="DbDescription" type="VARCHAR" size="512" required="false" defaultValue=""/>
  # <column name="starts" phpName="DbStarts" type="TIMESTAMP" required="true"/>
  # <column name="ends" phpName="DbEnds" type="TIMESTAMP" required="true"/>
  # <column name="show_id" phpName="DbShowId" type="INTEGER" required="true"/>
  # <column name="record" phpName="DbRecord" type="TINYINT" required="false" defaultValue="0"/>
  # <column name="rebroadcast" phpName="DbRebroadcast" type="TINYINT" required="false" defaultValue="0"/>
  # <column name="instance_id" phpName="DbOriginalShow" type="INTEGER" required="false"/>
  # <column name="file_id" phpName="DbRecordedFile" type="INTEGER" required="false"/>
  # <column name="time_filled" phpName="DbTimeFilled" type="VARCHAR" sqlType="interval" defaultValue="00:00:00" />
  # <column name="created" phpName="DbCreated" type="TIMESTAMP" required="true"/>
  # <column name="last_scheduled" phpName="DbLastScheduled" type="TIMESTAMP" required="false"/>
  # <!-- The purpose of the modified_instance column is to mark a show instance that was
  #    deleted when it was part of repeating show. This is useful because the way shows work,
  #    instances can be regenerated if we edit the show, which is unwanted behaviour. This column serves
  #    to ensure that we don't regenerate the instance. -->
  # <column name="modified_instance" phpName="DbModifiedInstance" type="BOOLEAN" required="true" defaultValue="false" />
  # <foreign-key foreignTable="cc_show" name="cc_show_fkey" onDelete="CASCADE">
  #    <reference local="show_id" foreign="id"/>
  # </foreign-key>
  # <foreign-key foreignTable="cc_show_instances" name="cc_original_show_instance_fkey" onDelete="CASCADE">
  #     <reference local="instance_id" foreign="id"/>
  # </foreign-key>
  # <foreign-key foreignTable="cc_files" name="cc_recorded_file_fkey" onDelete="CASCADE">
  #     <reference local="file_id" foreign="id"/>
  # </foreign-key>
  # rubocop:enable Layout/LineLength
  class ShowInstance < Base

    belongs_to :show

    scope :list, -> { where(modified_instance: false).order(:starts) }

    # A little hack to avoid DangerousAttributeErrors with the #record column.
    # Should not create issues as we do not write to Airtime anyways.
    def self.dangerous_attribute_method?(name)
      !%w[record_changed?].include?(name.to_s) && super
    end

  end
end
