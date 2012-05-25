class Admin::ProjectsController < ApplicationController
  before_filter :require_user
  # before_filter :check_permissions
  
  # GET /projects
  def index
    @member = current_member
    @admins = @member.admin?
    
    @projects = []
    if @member.admins_any_organization?
      @member.organizations_administered.each { |org| @projects.concat org.projects } 

      # Add the projects from the organizations it doesn't administers
      @member.projects.each { |proj| @projects << proj if(!@projects.include?(proj)) }
    else
      @projects = @member.projects
    end
  end

  # GET /projects/1
  def show
    @project = Project.find(params[:id])
  end

  # GET /projects/new
  def new
	  @project = Project.new
    @organization = (defined?(params[:organization])) ? params[:organization] : nil
    @free_projects = (defined?(params[:display_existing])) ? Project.free : @free_projects = nil
    @teams = @organization ? Team.all(:conditions => [ "organization_id = ? ", @organization ]) : []
    @selected = ''
    render :partial => 'form', 
      :object => @project,
    	:locals => { 
    	  :edit => false, 
    	  :organization => @organization, 
    	  :teams => @teams,
    	  :free_projects => @free_project
    	}, :status => :ok
  end

  # GET /projects/1/edit
  def edit
	  @project = Project.find(params[:id])
    @organization = @project.organization_id
    @teams = @organization ? Team.all(:conditions => [ "organization_id = ? ", @organization ]) : nil
    @selected = (@project.teams.empty?) ? nil : @project.teams.first.id
    render :partial => 'form', :object => @project, :locals => { :edit => true, :free_projects => nil }
  end

  # POST /projects
  def create
    @project = Project.new(params[:project])

    if @project.save
      if(params[:create_team])
        @team = Team.new
        @organization = @project.organization
        render :partial => 'admin/teams/form', :locals => { :edit => false, :organization =>  @organization, :project => @project }, :status => :ok
      else
        @project.teams << Team.find(params[:team_id])
        render :inline => "<script>location.reload(true);</script>", :status => :created
      end
    else
      @teams = Team.all(:conditions => [ "organization_id = ? ", @project.organization.id ])
      render :partial => 'form',
      		:object => @project,
      		:locals => { :no_refresh => true, :edit => false, :organization => @project.organization },
 		:status => :internal_server_error
    end
  end

  # PUT /projects/1
  def update
    @project = Project.find(params[:id])

    if @project.update_attributes(params[:project])
      @project.teams = [Team.find(params[:team_id])]
      render :inline => "<script>location.reload(true);</script>"
    else
        render :partial => 'form',
        		:object => @project,
        		:locals => { :no_refresh => true, :edit => true, :organization => @project.organization_id },
   		:status => :internal_server_error
    end
  end

  # DELETE /projects/1
  def destroy
    @project = Project.find(params[:id])
    # This is concateneted to [] to create a new array and not just reference it.
    if @project.destroy
      render :inline => "", :status => :ok
    else
      render :inline => "", :status => :internal_server_error
    end
  end
  
  def add_guest
    @member = Member.find_by_email(params[:email])
    @projects = (params[:projects]) ? params[:projects].to_a_with_no_index : []
    @error = @member.nil?

    # Add member to all projects
    @projects.each do |project| 
      if !@error 
        @guest_team_member = project.guest_team_memberships.create(:user => @member)
        @error = @guest_team_member.nil? 
      end
    end
    
    # Display an error if no project is selected
    if @projects.empty?
      @guest_team_member = GuestTeamMembership.new(:project => nil, :member => @member)
      @error = !@guest_team_member.save
    end
    
    # Display an error if no member is selected
    if @member.nil? && !@projects.empty?
      @guest_team_member = GuestTeamMembership.new(:project => Project.find(@projects[0]), :member => nil)
      @error = !@guest_team_member.save
    end

    # Send e-mail to the member
    MemberMailer.deliver_add_guest_to_projects(@member, current_user.name, @projects) if !@error

    render :partial => 'guest_team_member_form', :object => @guest_team_member, :locals => { :no_refresh => true, :edit => false, :organization => @organization = Organization.find(params[:organization]), :selected_projects => @projects }, :status => :internal_server_error if @error
    render :inline => "<script>location.reload(true);</script>", :status => :ok if !@error 
  end
  
  def update_guest
    @guest_member = Member.find(params[:member])
    @projects = (params[:projects]) ? params[:projects].to_a_with_no_index : []
    @error = false
    @guest_member_projects = []
    @organization = Organization.find(params[:organization])
    @organization.projects.each do |project|
      @guest_member_projects << project if project.guest_members.include?(@guest_member)
    end
    
    # Remove member from all the projects that he's not selected in update
    @guest_member_projects.each { |project| GuestTeamMembership.remove_from_project(@guest_member,project) if !@projects.include?(project.id) }
    
    
    @projects.each do |project| 
      if !@error 
          @project = Project.find(project)
          if !@project.guest_members.include?(@guest_member)
            @guest_team_member = GuestTeamMembership.new(:project => @project, :member => @guest_member) 
            @error = true if !@guest_team_member.save
          end
      end
    end
    render :partial => 'guest_team_member_form', :object => @guest_team_member, :locals => { :no_refresh => true, :edit => false, :organization => @organization = Organization.find(params[:organization]), :selected_projects => @projects }, :status => :internal_server_error if @error
    render :inline => "<script>location.reload(true);</script>", :status => :ok if !@error 
  end

  def remove_guest
    @member = Member.find(params[:member])
    @organization = Organization.find(params[:organization])
    GuestTeamMembership.remove_from_organization(@member, @organization)
    render :inline => "", :status => :ok
  end
  
  def new_guest_team_member
    @guest_team_member = GuestTeamMembership.new
	  @organization = Organization.find(params[:organization])
    render :partial => 'guest_team_member_form', :object => @guest_team_member, :locals => { 
        :edit => false,
    	  :organization => @organization, 
    	}, :status => :ok
  end

  def edit_guest_team_member
	  @organization = Organization.find(params[:organization])
    @guest_member = Member.find(params[:member])
    @guest_team_member = GuestTeamMembership.new(:member => @guest_member)
    @projects = []
    @organization.projects.each { |project| @projects << project.id if project.guest_members.include?(@guest_member)}
    
    render :partial => 'guest_team_member_form', :object => @guest_team_member, :locals => { 
        :edit => true,
    	  :organization => @organization, 
    	  :selected_projects => @projects
    	}, :status => :ok
  end

end
