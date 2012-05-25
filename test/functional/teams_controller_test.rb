require File.dirname(__FILE__) + '/../test_helper'

class Admin::TeamsControllerTest < ActionController::TestCase
  context "If i'm a normal user" do
    setup do
      @user = Factory(:user)
    end

  end

  context "If i'm an organization admin" do
    setup do
      @organization = Factory(:organization)
      @user = Factory(:user)
      @mem = @organization.organization_memberships.build(:user => @user)
      @mem.admin = true
      @mem.save
    end
    
    should "admin the organization" do
      assert @user.organizations_administered.include?(@organization)
    end

  end
  
  context "If I'm an admin" do
    setup do
      @user = admin_user
    end
    
  end
  # ########################## Permissions tests ##########################
  # test "show should be seen by administrator and organization admin" do 
  #   login_as_administrator
  #   get :show, :id => 1
  #   assert_response :ok
  # 
  #   login_as_organization_admin
  #   get :show, :id => 1
  #   assert_response :ok
  # 
  #   login_as_normal_user
  #   get :show, :id => 1
  #   assert_response 302
  # end
  # test "new should be seen by administrator and organization admin" do
  #     login_as_administrator
  #     get :new, :organization => organizations(:widmore_corporation).id
  #     assert_response :ok
  #     
  #     login_as_organization_admin
  #     get :new, :organization => organizations(:widmore_corporation).id
  #     assert_response :ok
  #     
  #     # If trying to get form for a organization not administered it shouln't work
  #     get :new, :organization => organizations(:dharma_initiative).id
  #     assert_response 302
  #   
  #     login_as_normal_user
  #     get :new, :organization => organizations(:dharma_initiative).id
  #     assert_response 302
  #   end
  # 
  # test "edit should be seen by administrator and organization admin" do
  #   login_as_administrator
  #   get :edit, :id => teams(:widmore_team).id
  #   assert_response :ok
  # 
  #   login_as_organization_admin
  #   get :edit, :id => teams(:widmore_team).id
  #   assert_response :ok
  # 
  #   login_as_normal_user
  #   get :edit, :id => teams(:widmore_team).id
  #   assert_response 302
  # end
  # 
  # test "a system adminsitrator should be able CREATE, UPDATE and DELETE teams for any organization" do
  #   login_as_administrator
  #   # CREATE to organization where admin belongs
  #   post :create,{ :team => { :name => 'Fucault Pendulum Research Team', :organization_id => organizations(:widmore_corporation).id } }
  #   assert_response :created
  #   team = Team.find_by_name('Fucault Pendulum Research Team')
  #   assert team
  #   assert organizations(:widmore_corporation).teams.include?(team)
  #   
  #   # CREATE to organization where admin doesn't belong
  #   post :create, { :team => {:name => 'Security Team', :organization_id => organizations(:dharma_initiative).id } }
  #   assert_response :created
  #   team_not_mine = Team.find_by_name('Security Team')
  #   assert team_not_mine
  #   assert organizations(:dharma_initiative).teams.include?(team_not_mine)
  #   
  #   # UPDATE from organization where admin belongs
  #   team = Team.find_by_name('Fucault Pendulum Research Team')
  #   put :update, { :id => team.id, :team => {:name => 'Fucault Pendulum Research Team.' } }
  #   assert_response :ok
  #   team.reload
  #   assert_equal 'Fucault Pendulum Research Team.', team.name
  # 
  #   # UPDATE from organization where admin doesn't
  #   team_notmine = Team.find_by_name('Security Team')
  #   put :update, { :id => team_notmine.id, :team => { :name => 'Security Team.' } }
  #   assert_response :ok
  #   team_notmine.reload
  #   assert_equal 'Security Team.', team_notmine.name
  # 
  #   # DELETE from organization where admin belongs
  #   delete :destroy, { :id => team.id }
  #   assert_response :ok
  #   assert_nil Team.find_by_name('Fucault Pendulum Research Team.')
  #   
  #   # DELETE from organization where admin doesn't belong
  #   delete :destroy, { :id => team_notmine.id }
  #   assert_response :ok
  #   assert_nil Team.find_by_name('Security Team.')
  # end
  # 
  # test "an organization admin should be able CREATE, UPDATE and DELETE teams for its organizations" do
  #   login_as_organization_admin
  # 
  #   # CREATE to organization where admin belongs
  #   post :create,{ :team => { :name => 'Fucault Pendulum Research Team', :organization_id => organizations(:widmore_corporation).id } }
  #   assert_response :created
  #   team = Team.find_by_name('Fucault Pendulum Research Team')
  #   assert team
  #   assert organizations(:widmore_corporation).teams.include?(team)
  #   
  #   # UPDATE from organization where admin belongs
  #   team = Team.find_by_name('Fucault Pendulum Research Team')
  #   put :update, { :id => team.id, :team => {:name => 'Fucault Pendulum Research Team.', :organization_id => organizations(:widmore_corporation).id } }
  #   assert_response :ok
  #   team.reload
  #   assert_equal 'Fucault Pendulum Research Team.', team.name
  #   
  #   # DELETE from organization where admin belongs
  #   delete :destroy, { :id => team.id }
  #   assert_response :ok
  #   assert_nil Team.find_by_name('Fucault Pendulum Research Team.')
  # end
  # 
  # test "an organization admin shouldn't be able CREATE, UPDATE and DELETE teams to another organization" do
  #   login_as_organization_admin
  #   
  #   # CREATE to organization where admin doesn't belong
  #   post :create, { :team => {:name => 'Security Team', :organization_id => organizations(:dharma_initiative).id } }
  #   assert_response 302
  #   assert !Team.find_by_name('Security Team')
  #   
  #   # UPDATE from organization where admin doesn't
  #   team_notmine = teams(:oceanic_six)
  #   put :update, { :id => team_notmine.id, :team => { :name => 'Dead People', :organization_id => organizations(:dharma_initiative).id } }
  #   assert_response 302
  #   team_notmine.reload
  #   assert_not_equal 'Dead People', team_notmine.name
  #   
  #   
  #   # DELETE from organization where admin doesn't belong
  #   delete :destroy, { :id => team_notmine.id }
  #   assert_response 302
  #   assert Team.find(team_notmine.id)
  # end 
  # 
  # test "a normal user shouldn't be able to CREATE, UPDATE and DELETE teams to any organization" do
  #   login_as_normal_user
  #   
  #   # CREATE
  #   post :create, { :team => {:name => 'Security Team', :organization_id => organizations(:widmore_corporation).id } }
  #   assert_response 302
  #   assert !Team.find_by_name('Security Team')
  #   
  #   # UPDATE
  #   team_notmine = teams(:oceanic_six)
  #   put :update, { :id => team_notmine.id, :team => { :name => 'Dead People', :organization_id => organizations(:widmore_corporation).id } }
  #   assert_response 302
  #   team_notmine.reload
  #   assert_not_equal 'Dead People', team_notmine.name
  #   
  #   
  #   # DELETE
  #   delete :destroy, { :id => team_notmine.id }
  #   assert_response 302
  #   assert Team.find(team_notmine.id)  
  # end
  # 
  # test "an organization admin should be able to add & remove members for teams within its organizations" do
  #   login_as_organization_admin
  # 
  #   # ADD MEMBER with team and member belonging to organization
  #   post :add_member,{ :team => teams(:widmore_team), :member => members(:cwidmore) }
  #   assert_response :ok
  #   assert teams(:widmore_team).members.include?(members(:cwidmore))
  # 
  #   # ADD MEMBER with team belonging to organization
  #   post :add_member,{ :team => teams(:widmore_team), :member => members(:mdawson) }
  #   assert_response 302
  #   assert !teams(:widmore_team).members.include?(members(:mdawson))
  #   
  #   # ADD MEMBER with member belonging to organization
  #   post :add_member,{ :team => teams(:oceanic_six), :member => members(:clittleton) }
  #   assert_response 302
  #   assert !teams(:oceanic_six).members.include?(members(:clittleton))
  # 
  #   # ADD MEMBER with none belonging to organization
  #   post :add_member,{ :team => teams(:oceanic_six), :member => members(:mdawson) }
  #   assert_response 302
  #   assert !teams(:oceanic_six).members.include?(members(:mdawson))
  # 
  #   # REMOVE MEMBER with team and member belonging to organization
  #   post :remove_member,{ :team => teams(:widmore_team), :member => members(:cwidmore) }
  #   assert_response :ok
  #   assert !teams(:widmore_team).members.include?(members(:cwidmore))
  # 
  #   # REMOVE MEMBER with none belonging to organization
  #   post :remove_member,{ :team => teams(:oceanic_six), :member => members(:jshephard) }
  #   assert_response 302
  #   assert teams(:oceanic_six).members.include?(members(:jshephard))
  #   
  # end
  # 
end
