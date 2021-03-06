class Dog
attr_accessor :name, :breed, :id

  def initialize (hash)
    @name = hash[:name]
    @breed = hash[:breed]
    @id = hash[:id]
    
  end

  def self.create_table
    sql=<<SQL
    CREATE TABLE dogs(
      id INTEGER PRIMARY KEY,
      name TEXT, 
      BREED TEXT
    )
SQL
      DB[:conn].execute(sql)
 end

 def self.drop_table
    sql=<<SQL
    DROP TABLE IF EXISTS dogs
SQL
  DB[:conn].execute(sql)
end

def save
  sql=<<SQL
  INSERT INTO dogs( name, breed)
  VALUES(?,?)
SQL
  DB[:conn].execute(sql, self.name, self.breed)
  new_instance = DB[:conn].execute("SELECT id, name, breed FROM dogs WHERE name = ? AND breed = ?", name, breed)
  first_row = new_instance[0]
  @id = first_row[0]
  self
end
    
def self.create(hash)
  dog_instance = self.new(hash)
  dog_instance.save
  dog_instance
end

def self.find_by_id(id)
  sql=<<SQL
    SELECT id, name, breed
    FROM dogs
    WHERE id = ?
SQL
  result = DB[:conn].execute(sql, id)[0]
  self.new({:id => result[0], :name  => result[1], :breed =>result[2]})
end

def self.find_or_create_by( name:, breed:)
  dog = DB[:conn].execute('SELECT id, name, breed FROM dogs WHERE name = ? AND breed =?', name, breed)
  if !dog.empty?
    dog_info = dog[0]
    dog = self.new({:id => dog_info[0], :name => dog_info[1], :breed =>dog_info[2]})
  else
    dog = self.create(name: name, breed:breed)
  end
  dog 
end

  def self.new_from_db(row)
    new_dog = self.new({:id => row[0], :name =>row[1], :breed =>row[2]})
    new_dog
  end
  
  def self.find_by_name(name)
    sql =<<SQL
    SELECT * 
    FROM dogs 
    WHERE name = ?
SQL
    result = DB[:conn].execute(sql, name)[0]
    dog = self.new(:id => result[0], :name =>result[1], :breed =>result[2])
    dog
  end

  def update
    sql=<<SQL
    UPDATE dogs
    SET name = ?,
    breed = ?
    WHERE id = ?
SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end