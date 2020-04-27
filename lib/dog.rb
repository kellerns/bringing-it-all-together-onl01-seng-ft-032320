class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT)
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end


  def self.create(dog_hash)
    new_dog = Dog.new(dog_hash)
    new_dog.save
    new_dog
  end

  def self.new_from_db(row)
    dog_hash = {id: row[0], name: row[1], breed: row[2]}
    self.new(dog_hash)
  end

  def self.find_by_id(dog_id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, dog_id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      AND breed = ?
    SQL


    dog = DB[:conn].execute(sql, name, breed).first

    if !dog.empty?
      new_dog = self.new_from_db(dog)
    else
      new_dog = self.create(name: name, breed: breed)
    end
    new_dog
  end

  def find_by_name(dog_name)

  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
