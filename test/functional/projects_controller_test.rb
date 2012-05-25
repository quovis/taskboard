require File.dirname(__FILE__) + '/../test_helper'

class Admin::ProjectsControllerTest < ActionController::TestCase
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
  # test "index, if logged in as admin i should see all projects" do
  #   login_as_administrator
  #   get :index
  #   assert_response :ok
  #   assert_select "div.project-container", :count => Project.all.size
  # end
  # 
  # test "index, if logged in as organization admin i should see all projects within the organization" do
  #   login_as_organization_admin
  #   get :index
  #   assert_response :ok
  # 
  #   expected_projects = []
  #   members(:cwidmore).organizations_administered.each do |organization|
  #     expected_projects += organization.projects
  #   end
  #   assert_select "div.project-container", :count => expected_projects.size
  # end
  # 
  # test "index, if logged in as organization admin i should see the projects i'm in with color" do
  #   login_as_organization_admin
  #   get :index
  #   assert_response :ok
  #   
  # end
  # 
  # test "index, if logged in as organization admin i should see the projects i'm not in with grey" do
  #   login_as_organization_admin
  #   get :index
  #   assert_response :ok
  # end
  # 
  # test "index, if logged in as normal user and have only one project, i should see the list" do
  #   login_as(members(:jburke))
  #   get :index
  #   assert_response :ok
  #   assert_select "div.project-container", :count => members(:jburke).projects.size
  # end
  # 
  # test "index, if logging in as normal user and have more than one project, i should see the list" do
  #   login_as(members(:jshephard))
  #   get :index
  #   assert_response :ok
  #   assert_select "div.project-container", :count => members(:jshephard).projects.size
  # end
  # 
  # test "when a project is created, the team should be assigned to it" do
  #   login_as_organization_admin
  #   post :create, { :project => {:name => 'Find Jacob Again' , :organization_id => organizations(:widmore_corporation).id}, :team_id => 1}
  #   assert project = Project.find_by_name('Find Jacob Again')
  #   assert project.teams.first == Team.find(1)
  # end
  # 
  # test "when a project is updated, the team should be assigned to it" do
  #   login_as_organization_admin
  #   project = Project.find(1)
  #   post :update, { :id => project.id, :project => { :name => 'Find Jacob Again Agait' , :organization_id => organizations(:widmore_corporation).id}, :team_id => 2}
  #   project.reload
  #   assert project.teams.first == Team.find(2)
  # end
  # 
  # test "adding a guest member to multiple projects works" do
  #   login_as_organization_admin
  #   # with nil
  #   post :add_guest, { :projects => { }, :email => "kausten@lost.com", :organization => organizations(:widmore_corporation) }
  #   assert_response :internal_server_error
  #   # with more than one project
  #   post :add_guest, { :projects => { "#{projects(:find_the_island).id}" => projects(:find_the_island).id, "#{projects(:fake_planecrash).id}" => projects(:fake_planecrash).id,  }, :email => "kausten@lost.com", :organization => organizations(:widmore_corporation).id }
  #   assert_response :ok
  #   assert projects(:find_the_island).guest_members.include?(members(:kausten))
  #   assert projects(:fake_planecrash).guest_members.include?(members(:kausten))
  # end
  # 
  # test "removing a guest member from multiple projects works" do
  #   login_as_organization_admin
  #   post :add_guest, { :projects => { "#{projects(:find_the_island).id}" => projects(:find_the_island).id, "#{projects(:fake_planecrash).id}" => projects(:fake_planecrash).id,  }, :email => "kausten@lost.com", :organization => organizations(:widmore_corporation).id }
  #   assert projects(:find_the_island).guest_members.include?(members(:kausten))
  #   assert projects(:fake_planecrash).guest_members.include?(members(:kausten))
  #   post :remove_guest, { :organization => organizations(:widmore_corporation).id, :member => members(:kausten)}
  #   assert_response :ok
  #   assert !projects(:find_the_island).guest_members.include?(members(:kausten))
  #   assert !projects(:fake_planecrash).guest_members.include?(members(:kausten))
  # end
  # ########################## Permissions tests ##########################
  # test "new should be seen by administrator and organization admin" do
  #   login_as_administrator
  #   get :new, :organization => 1
  #   assert_response :ok
  #   # administrator can call the form without an organization to select it from a drow down menu.
  #   get :new
  #   assert_response :ok
  #   
  #   login_as_organization_admin
  #   get :new, :organization => 1
  #   assert_response :ok
  #   
  #   # If trying to get form for a organization not administered it shouln't work
  #   get :new, :organization => 2
  #   assert_response 302
  # 
  #   # THIS IS NOT ANYMORE LIKE THIS, YOU CANNOT CALL NEW WITHOUT AN ORGANIZATION
  #   # If trying to get form without an organization, it should only see the organizations it administers
  #   #get :new
  #   #assert_response :ok
  #   #assert_select "option", :count => members(:cwidmore).organizations_administered.size
  # 
  #   login_as_normal_user
  #   get :new, :organization => 1
  #   assert_response 302
  # end
  # 
  # test "edit should be seen by administrator and organization admin" do
  #   login_as_administrator
  #   get :edit, :id => 1
  #   assert_response :ok
  #   
  #   login_as_organization_admin
  #   get :edit, :id => 1
  #   assert_response :ok
  # 
  #   login_as_normal_user
  #   get :edit, :id => 1
  #   assert_response 302
  # end
  # 
  # test "a system adminsitrator should be able CREATE, UPDATE and DELETE projects for any organization" do
  #   login_as_administrator
  #   # CREATE to organization where admin belongs
  #   post :create, { :project => {:name => 'Find Jacob', :organization_id => organizations(:widmore_corporation).id }, :team_id => 1 }
  #   assert_response :created
  #   assert Project.find_by_name('Find Jacob')
  # 
  #   # CREATE to organization where admin doesn't belong
  #   post :create, { :project => {:name => 'Destroy the magnetic zone', :organization_id => organizations(:dharma_initiative).id }, :team_id => 1 }
  #   assert_response :created
  #   assert Project.find_by_name('Destroy the magnetic zone')
  #   
  #   # UPDATE from organization where admin belongs
  #   project = Project.find_by_name('Find Jacob')
  #   put :update, { :id => project.id, :project => {:name => 'Find Jacob.' }, :team_id => 1 }
  #   assert_response :ok
  #   project.reload
  #   assert_equal 'Find Jacob.', project.name
  # 
  #   # UPDATE from organization where admin doesn't
  #   project_notmine = Project.find_by_name('Destroy the magnetic zone')
  #   put :update, { :id => project_notmine.id, :project => {:name => 'Destroy the magnetic zone.' }, :team_id => 1 }
  #   assert_response :ok
  #   project_notmine.reload
  #   assert_equal 'Destroy the magnetic zone.', project_notmine.name
  #   
  #   # DELETE from organization where admin belongs
  #   delete :destroy, { :id => project.id }
  #   assert_response :ok
  #   assert_nil Project.find_by_name('Find Jacob.')
  #   
  #   # DELETE from organization where admin doesn't belong
  #   delete :destroy, { :id => project_notmine.id }
  #   assert_response :ok
  #   assert_nil Project.find_by_name('Destroy the magnetic zone.')
  # end
  # 
  # test "an organization admin should be able CRUD projects for its organizations" do
  #   login_as_organization_admin
  # 
  #   # CREATE to organization where admin belongs
  #   post :create, { :project => {:name => 'Find Jacob' , :organization_id => organizations(:widmore_corporation).id}, :team_id => 1}
  #   assert_response :created
  #   project = Project.find_by_name('Find Jacob')
  #   assert project
  #   assert project.organization == organizations(:widmore_corporation)
  #   
  #   # UPDATE from organization where admin belongs
  #   project = Project.find_by_name('Find Jacob')
  #   put :update, { :id => project.id, :project => {:name => 'Find Jacob.' }, :team_id => 1 }
  #   assert_response :ok
  #   project.reload
  #   assert_equal 'Find Jacob.', project.name
  #   
  #   # DELETE from organization where admin belongs
  #   delete :destroy, { :id => project.id }
  #   assert_response :ok
  #   assert_nil Project.find_by_name('Find Jacob.')
  # end
  # 
  # test "an organization admin shouldn't be able CRUD projects to another organization" do
  #   login_as_organization_admin
  #   
  #   # CREATE to organization where admin doesn't belong
  #   post :create, { :project => {:name => 'Destroy the magnetic zone', :organization_id => organizations(:dharma_initiative).id}, :team_id => 1 }
  #   assert_response 302
  #   assert !Project.find_by_name('Destroy the magnetic zone')
  #   
  #   # UPDATE from organization where admin doesn't
  #   project_notmine = projects(:come_back_to_the_island)
  #   put :update, { :id => project_notmine.id, :project => {:name => 'Get off of the island' } }
  #   assert_response 302
  #   project_notmine.reload
  #   assert_not_equal 'Get off of the island', project_notmine.name
  #   
  #   # DELETE from organization where admin doesn't belong
  #   delete :destroy, { :id => project_notmine.id }
  #   assert_response 302
  #   assert Project.find(project_notmine.id)
  # end 
  # 
  # test "a normal user shouldn't be able to CRUD projects to any organization" do
  #   login_as_normal_user
  #   
  #   # CREATE
  #   post :create, { :project => {:name => 'Destroy the magnetic zone', :organization_id => organizations(:dharma_initiative).id }, :team_id => 1 }
  #   assert_response 302
  #   assert !Project.find_by_name('Destroy the magnetic zone')
  #   
  #   # UPDATE
  #   project_notmine = projects(:come_back_to_the_island)
  #   put :update, { :id => project_notmine.id, :project => {:name => 'Get off of the island' } }
  #   assert_response 302
  #   project_notmine.reload
  #   assert_not_equal 'Get off of the island', project_notmine.name
  #   
  #   # DELETE
  #   delete :destroy, { :id => project_notmine.id }
  #   assert_response 302
  #   assert_nil Project.find_by_name('Destroy the magnetic zone.')    
  # end
  # 
  # test "a system administrator can add a guest member to any project" do
  #   login_as_administrator
  # 
  #   get :new_guest_team_member, { :organization => organizations(:dharma_initiative) }
  #   assert_response :ok
  #   post :add_guest, { :projects => { "#{projects(:do_weird_experiments).id}" => projects(:do_weird_experiments).id }, :email => "dfaraday@widmore.com", :organization => organizations(:dharma_initiative).id}
  #   assert_response :ok
  #   assert projects(:do_weird_experiments).guest_members.include?(members(:dfaraday))
  #   get :edit_guest_team_member, { :member => members(:dfaraday), :organization => organizations(:dharma_initiative) }
  #   assert_response :ok
  #   post :update_guest, { :projects => { }, :member => members(:dfaraday).id, :organization => organizations(:dharma_initiative).id}
  #   assert_response :ok
  #   assert !projects(:do_weird_experiments).guest_members.include?(members(:dfaraday))
  #   post :add_guest, { :projects => { "#{projects(:do_weird_experiments).id}" => projects(:do_weird_experiments).id }, :email => "dfaraday@widmore.com", :organization => organizations(:dharma_initiative).id}
  #   assert projects(:do_weird_experiments).guest_members.include?(members(:dfaraday))
  #   post :remove_guest, { :organization => organizations(:dharma_initiative).id, :member => members(:dfaraday).id}
  #   assert_response :ok
  #   assert !projects(:do_weird_experiments).guest_members.include?(members(:dfaraday))
  # 
  #   get :new_guest_team_member, { :organization => organizations(:widmore_corporation) }
  #   assert_response :ok
  #   post :add_guest, { :projects => { "#{projects(:find_the_island).id}" => projects(:find_the_island).id }, :email => "kausten@lost.com", :organization => organizations(:widmore_corporation).id }
  #   assert_response :ok
  #   get :edit_guest_team_member, { :member => members(:kausten), :organization => organizations(:widmore_corporation) }
  #   assert_response :ok
  #   post :update_guest, { :projects => { }, :member => members(:kausten).id, :organization => organizations(:widmore_corporation).id}
  #   assert_response :ok
  #   assert !projects(:find_the_island).guest_members.include?(members(:kausten))
  #   post :add_guest, { :projects => { "#{projects(:find_the_island).id}" => projects(:find_the_island).id }, :email => "kausten@lost.com", :organization => organizations(:widmore_corporation).id }
  #   assert projects(:find_the_island).guest_members.include?(members(:kausten))
  #   post :remove_guest, { :organization => organizations(:widmore_corporation).id, :member => members(:kausten).id}
  #   assert_response :ok
  #   assert !projects(:find_the_island).guest_members.include?(members(:kausten))
  # end
  # 
  # test "an organization administrator can add a guest member to projects within its organization" do
  #   login_as_organization_admin
  #   get :new_guest_team_member, { :organization => organizations(:widmore_corporation) }
  #   assert_response :ok
  #   post :add_guest, { :projects => { "#{projects(:find_the_island).id}" => projects(:find_the_island).id }, :email => "kausten@lost.com", :organization => organizations(:widmore_corporation).id }
  #   assert_response :ok
  #   get :edit_guest_team_member, { :member => members(:kausten), :organization => organizations(:widmore_corporation) }
  #   assert_response :ok
  #   post :update_guest, { :projects => { }, :member => members(:kausten).id, :organization => organizations(:widmore_corporation).id}
  #   assert_response :ok
  #   assert !projects(:find_the_island).guest_members.include?(members(:kausten))
  #   post :add_guest, { :projects => { "#{projects(:find_the_island).id}" => projects(:find_the_island).id }, :email => "kausten@lost.com", :organization => organizations(:widmore_corporation).id }
  #   assert projects(:find_the_island).guest_members.include?(members(:kausten))
  #   post :remove_guest, { :organization => organizations(:widmore_corporation).id, :member => members(:kausten).id}
  #   assert_response :ok
  #   assert !projects(:find_the_island).guest_members.include?(members(:kausten))
  #   get :new_guest_team_member, { :organization => organizations(:dharma_initiative) }
  #   assert_response 302
  #   get :edit_guest_team_member, { :member => members(:dfaraday), :organization => organizations(:dharma_initiative) }
  #   assert_response 302
  #   post :update_guest, { :projects => { }, :member => members(:dfaraday).id, :organization => organizations(:dharma_initiative).id}
  #   assert_response 302
  #   post :add_guest, { :projects => { "#{projects(:do_weird_experiments).id}" => projects(:do_weird_experiments).id }, :email => "dfaraday@widmore.com", :organization => organizations(:dharma_initiative).id}
  #   assert_response 302
  #   assert !projects(:do_weird_experiments).guest_members.include?(members(:dfaraday))
  #   post :add_guest, { :projects => { "#{projects(:do_weird_experiments).id}" => projects(:do_weird_experiments).id }, :email => "dfaraday@widmore.com", :organization => organizations(:widmore_corporation).id}
  #   assert_response 302
  #   assert !projects(:do_weird_experiments).guest_members.include?(members(:dfaraday))
  #   post :remove_guest, { :organization => organizations(:dharma_initiative).id, :member => members(:dfaraday).id}
  #   assert_response 302
  # end
  # 
  # test "a normal user can't add guest members" do
  #   login_as_normal_user
  #   get :new_guest_team_member, { :organization => organizations(:widmore_corporation) }
  #   assert_response 302
  #   get :edit_guest_team_member, { :member => members(:kausten), :organization => organizations(:widmore_corporation) }
  #   assert_response 302
  #   post :update_guest, { :projects => { }, :member => members(:kausten).id, :organization => organizations(:widmore_corporation).id}
  #   assert_response 302
  #   post :add_guest, { :projects => { "#{projects(:find_the_island).id}" => projects(:find_the_island).id }, :email => "kausten@lost.com" , :organization => organizations(:widmore_corporation).id}
  #   assert_response 302
  #   assert !projects(:find_the_island).guest_members.include?(members(:kausten))
  #   post :remove_guest, { :organization => organizations(:widmore_corporation).id, :member => members(:kausten).id}
  #   assert_response 302
  #   assert !projects(:find_the_island).guest_members.include?(members(:kausten))
  # 
  #   get :new_guest_team_member, { :organization => organizations(:dharma_initiative) }
  #   assert_response 302
  #   get :edit_guest_team_member, { :member => members(:dfaraday), :organization => organizations(:dharma_initiative) }
  #   assert_response 302
  #   post :add_guest, { :projects => { "#{projects(:do_weird_experiments).id}" => projects(:do_weird_experiments).id }, :email => "dfaraday@widmore.com", :organization => organizations(:dharma_initiative).id}
  #   assert_response 302
  #   post :update_guest, { :projects => { }, :member => members(:dfaraday).id, :organization => organizations(:dharma_initiative).id}
  #   assert_response 302
  #   post :remove_guest, { :organization => organizations(:dharma_initiative).id, :member => members(:dfaraday).id}
  #   assert_response 302
  #   assert !projects(:do_weird_experiments).guest_members.include?(members(:dfaraday))
  # end
  # 
end
