# frozen_string_literal: true

# == Schema Information
#
# Table name: cc_show
#
#  id                             :integer          not null, primary key
#  name                           :string(255)      not null
#  url                            :string(255)
#  genre                          :string(255)
#  description                    :string(512)
#  color                          :string(6)
#  background_color               :string(6)
#  live_stream_using_airtime_auth :boolean          default(FALSE)
#  live_stream_using_custom_auth  :boolean          default(FALSE)
#  live_stream_user               :string(255)
#  live_stream_pass               :string(255)
#  linked                         :boolean          default(FALSE), not null
#  is_linkable                    :boolean          default(TRUE), not null
#

module Airtime
  # rubocop:disable Layout/LineLength
  # <column name="id" phpName="DbId" type="INTEGER" primaryKey="true" autoIncrement="true" required="true"/>
  # <column name="name" phpName="DbName" type="VARCHAR" size="255" required="true" defaultValue=""/>
  # <column name="url" phpName="DbUrl" type="VARCHAR" size="255" required="false" defaultValue=""/>
  # <column name="genre" phpName="DbGenre" type="VARCHAR" size="255" required="false" defaultValue=""/>
  # <column name="description" phpName="DbDescription" type="VARCHAR" size="512" required="false"/>
  # <column name="color" phpName="DbColor" type="VARCHAR" size="6" required="false"/>
  # <column name="background_color" phpName="DbBackgroundColor" type="VARCHAR" size="6" required="false"/>
  # <column name="live_stream_using_airtime_auth" phpName="DbLiveStreamUsingAirtimeAuth" type="BOOLEAN" required="false" defaultValue="false"/>
  # <column name="live_stream_using_custom_auth" phpName="DbLiveStreamUsingCustomAuth" type="BOOLEAN" required="false" defaultValue="false"/>
  # <column name="live_stream_user" phpName="DbLiveStreamUser" type="VARCHAR" size="255" required="false"/>
  # <column name="live_stream_pass" phpName="DbLiveStreamPass" type="VARCHAR" size="255" required="false"/>
  # <column name="linked" phpName="DbLinked" type="BOOLEAN" required="true" defaultValue="false" />
  # <column name="is_linkable" phpName="DbIsLinkable" type="BOOLEAN" required="true" defaultValue="true" />
  # <!-- A show is_linkable if it has never been linked before. Once a show becomes unlinked
  #      it can not be linked again -->
  # <column name="image_path" phpName="DbImagePath" type="VARCHAR" size="255" required="false" defaultValue=""/>
  # <!-- Fully qualified path for the image associated with this show.
  #      Default is /path/to/stor/dir/:ownerId/show-images/:showId/imageName -->
  # rubocop:enable Layout/LineLength
  class Show < Base

    self.table_name = 'cc_show'

    has_many :show_instances, dependent: :destroy

  end
end
