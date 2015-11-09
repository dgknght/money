module EntityHelpers
  def find_entity(name)
    entity = Entity.find_by_name(name)
    expect(entity).not_to be_nil
    entity
  end
end
World(EntityHelpers)
