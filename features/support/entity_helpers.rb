module EntityHelpers
  def find_entity(name)
    entity = Entity.find_by_name(name)
    entity.should_not be_nil
    entity
  end
end
World(EntityHelpers)