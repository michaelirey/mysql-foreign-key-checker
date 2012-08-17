require 'mysql2'
require 'yaml'


class ForeignKeys

    def initialize
      @config = YAML::load(File.open(File.dirname(File.expand_path(__FILE__)) + '/db.yml'))      
      @client = Mysql2::Client.new(
        :host => @config['host'],
        :port => @config['port'],
        :username => @config['username'],
        :password => @config['password'],
        :database => @config['database'])
        
      get_foreign_keys_from_database
    end
    
    def get_foreign_keys_from_database
      @foreign_keys = @client.query("SELECT `TABLE_NAME`, `COLUMN_NAME`, `REFERENCED_TABLE_NAME`, `REFERENCED_COLUMN_NAME`  FROM information_schema.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA='#{@config['database']}' AND REFERENCED_TABLE_SCHEMA IS NOT NULL;")
    end

    
    def check_all_forgein_keys
      @foreign_keys.each do |fk|
        check_foreign_key(fk)
      end
    end
    
      
    def check_foreign_key(foreign_key)
      
      puts "Checking #{foreign_key['TABLE_NAME']}.#{foreign_key['COLUMN_NAME']}"
      
      if(foreign_key['TABLE_NAME'] == foreign_key['REFERENCED_TABLE_NAME']) 
        sql = "SELECT t1.* FROM #{foreign_key['TABLE_NAME']} t1 LEFT JOIN #{foreign_key['REFERENCED_TABLE_NAME']} t2 ON (t1.#{foreign_key['COLUMN_NAME']}=t2.#{foreign_key['REFERENCED_COLUMN_NAME']}) WHERE t1.#{foreign_key['COLUMN_NAME']} IS NOT NULL AND t2.#{foreign_key['REFERENCED_COLUMN_NAME']} IS NULL"
      else 
        sql = "SELECT #{foreign_key['TABLE_NAME']}.* FROM #{foreign_key['TABLE_NAME']} LEFT JOIN #{foreign_key['REFERENCED_TABLE_NAME']} ON (#{foreign_key['TABLE_NAME']}.#{foreign_key['COLUMN_NAME']}=#{foreign_key['REFERENCED_TABLE_NAME']}.#{foreign_key['REFERENCED_COLUMN_NAME']}) WHERE #{foreign_key['TABLE_NAME']}.#{foreign_key['COLUMN_NAME']} IS NOT NULL AND #{foreign_key['REFERENCED_TABLE_NAME']}.#{foreign_key['REFERENCED_COLUMN_NAME']} IS NULL"
      end

        results = @client.query(sql)
        if(results.count > 0) 
          puts "Found #{results.count} Invalid Foreign Keys"
          puts sql
        end
    end


end


fk = ForeignKeys.new
fk.check_all_forgein_keys