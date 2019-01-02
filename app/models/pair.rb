class Pair < ApplicationRecord
    belongs_to :member_a, :class_name => :Member
    belongs_to :member_b, :class_name => :Member

    @@members = []
    @@pairs = []
    @@paired = []

    def self.create_pairs
        self.prepair
        @@members.each do |a|
            if !@@paired.include?(a)
                b = a.pairable.detect{|p| !@@paired.include?(p) }
                self.add_pair(a, b) if b
                self.steel_pair(a) if !b
            end
        end
        self.save_pairs
    end

    def self.add_pair(a, b)
        @@pairs << self.new(member_a_id: a.id, member_b_id: b.id, current: true)
        @@paired << a
        @@paired << b
    end 

    def self.steel_pair(a)
        np = @@members.select{|mem| !@@paired.include?(mem)}
        @@pairs.detect do |p|
            bp = p.member_b.pairable.detect{ |mem| np.include?(mem)}
            ap = p.member_a.pairable.detect{ |mem| np.include?(mem)}
            if (a.pairable.include?(p.member_a) && bp) || (a.pairable.include?(p.member_b) && ap)
                if a.pairable.include?(p.member_a) && bp
                    self.add_pair(bp, p.member_b)
                    binding.pry
                    p.member_b = a.id
                    @@paired << a
                else
                    binding.pry
                    self.add_pair(ap, p.member_a)
                    p.member_a = a.id
                    @@paired << a
                end
            else 
                # pairs = @@pairs
                # pairs.each do |pair| 
                #     new_set = []
                #     if p.member_a.pairable.include?(pair.member_a) && p.member_b.pairable.include?(pair.member_b)
                #         new_set << self.new(member_a_id: a.id, member_b_id: p.member_a.id, current: true)
                #     else 
                #         new_set << p
                #     end
                # end
                # @@pairs = new_set
            end
        end
    end 

    def self.prepair
        @@members = Member.where(active: true).shuffle
        num = 0
        @@members.each do |mem| 
            num = mem.pairs.size if num < mem.pairs.size 
        end
        if num >= @@members.size - 1
            Pair.delete_all
        else 
            update_all(current: false)
        end
    end

    def self.save_pairs
        @@pairs.each {|p| p.save}
    end

end
