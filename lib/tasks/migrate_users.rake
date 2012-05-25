require File.expand_path(File.dirname(__FILE__) + "/../../config/environment")
require 'digest/sha1'
namespace :taskboard do
  namespace :migration do
    task :all => [ :environment, :users ]
    
    task :users do
      puts "Creating users..."
      @members = Member.all
      @members_size = @members.size
      
      @members.each_with_index do |member, index|
        puts "Creating user (#{member.id} - #{member.username}): #{index + 1}/#{@members_size}"
        # Create the user
        @user = User.new(
          :name => member.name, 
          :color => member.color, 
          :login => member.username, 
          :email => member.email ? member.email : "insert#{Digest::SHA1.hexdigest(member.username)}@mail.com", 
          :avatar => FileTest.exists?(File.join(Rails.root, 'public', 'images', 'members', member.id.to_s + '.png')) ? File.open(File.join(Rails.root, 'public', 'images', 'members', member.id.to_s + '.png')) : nil,
          :password => Digest::SHA1.hexdigest(member.username), 
          :password_confirmation => Digest::SHA1.hexdigest(member.username)
        )
        
        # Save the user
        if @user.save
          # Set if the user is an admin
          @user.admin = member.admin?
          @user.save
          
          # puts "Adding user teams"
          @user.teams = member.teams
          # puts "Adding organization memberships"
          member.organization_memberships.each do |om|
            om.user = @user
            om.save
          end

          # puts "Adding organization memberships"
          member.guest_team_memberships.each do |om|
            om.user = @user
            om.save
          end
          
          # Migrate all nametags
          member.nametags.each do |n|
            n.user = @user
            n.save
          end

        else
          p "Error adding #{member.id} - #{member.username}:"
          p @user.errors.inspect
        end
      end
    end
  end
end