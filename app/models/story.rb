class Story < ActiveRecord::Base
  ################################################################################################################
  #
  # Associations
  #
  ################################################################################################################
  belongs_to :project
  has_many :tasks, :dependent => :destroy

  ################################################################################################################
  #
  # Validations
  #
  ################################################################################################################
  validates_presence_of :realid, :project, :name, :priority
  validates_numericality_of :priority
  ################################################################################################################
  #
  # Attributes Accessible
  #
  ################################################################################################################
  attr_accessible :name, :priority, :size, :description, :realid, :project, :release

  ################################################################################################################
  #
  # Named Scopes
  #
  ################################################################################################################
  default_scope :order => "priority DESC, updated_at DESC"
  named_scope :in_progress, :conditions => {:status => 'in_progress'}
  named_scope :not_started, :conditions => {:status => 'not_started'}
  named_scope :finished, :conditions => {:status => 'finished'}

  ################################################################################################################
  #
  # CALLBACKS
  #
  ################################################################################################################
  before_save :set_default_priority, :set_default_realid
  before_create :set_default_priority, :set_default_realid
  after_create :add_template_task

  after_create :create_harvest_task_and_assignment, :unless => proc {|story| story.project.harvest_project_id.blank? }
  after_update :update_harvest_task, :if     => proc {|story| story.name_changed? || story.realid_changed? }

  def after_initialize
    set_default_priority if project
    set_default_realid if project
  end
  
  ################################################################################################################
  #
  # Instance Methods
  #
  ################################################################################################################
  def stopped?
    self.status == 'not_started'
  end

  def started?
    self.status == 'in_progress'
  end

  def finished?
    self.status == 'finished'
  end

  def start
    self.priority = old_priority if finished?
    self.status = 'in_progress'
    return self.save
  end

  def stop
    self.status = 'not_started'
    return self.save
  end

  def finish
    self.status = 'finished'
    self.old_priority = priority
    self.priority = -1
    return self.save
  end

  def default_priority
    return self.priority = -1 if self.finished?
    return self.priority if self.priority && self.priority >= 0
    return self.priority = 0 if self.priority && self.priority < 0
    return project.next_priority
  end

  def harvest_task_name
    "[#{realid}] #{name}"
  end

  def to_harvest_task
    if harvest_task_id
      Harvest::Task.new(:id => harvest_task_id, :name => harvest_task_name)
    else
      Harvest::Task.new(:name => harvest_task_name)
    end
  end

private  

  def add_template_task
    self.tasks << Task.new(:name => "Add tasks")
  end

  def set_default_priority
    self.priority = default_priority if !priority
  end
  
  def set_default_realid
    self.realid = project.next_realid if !realid
  end

  def create_harvest_task_and_assignment
    # TODO: Move this to a queued process
    if create_harvest_task
      create_harvest_task_assignment
      self.class.update_all({ :harvest_task_id => harvest_task_id }, :id => id)
    end
  end

  def create_harvest_task
    if task = HARVEST_CLIENT.tasks.create(to_harvest_task)
      self.harvest_task_id = task.id
    end
  end

  def create_harvest_task_assignment
    HARVEST_CLIENT.task_assignments.create(:project_id => project.harvest_project_id, :task_id => harvest_task_id)
  end

  def update_harvest_task
    HARVEST_CLIENT.tasks.update(to_harvest_task)
  end
end
