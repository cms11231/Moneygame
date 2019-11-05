require 'gosu'

class Tutorial < Gosu::Window
    def initialize
        super 640, 480
        self.caption = "Tutorial Game"
  
        @background_image = Gosu::Image.new("media/land.jpg", :tileable => true)
  
        @player = Player.new
        @player.warp(320, 240)

        @star_anim = Gosu::Image.load_tiles("media/star.png", 25, 25)
        @stars = Array.new
        @bigs = Array.new
        @font = Gosu::Font.new(20)
    end
  
    def update
        if Gosu.button_down? Gosu::KB_LEFT or Gosu::button_down? Gosu::GP_LEFT
            @player.go_left
        end
        if Gosu.button_down? Gosu::KB_RIGHT or Gosu::button_down? Gosu::GP_RIGHT
            @player.go_right
        end
        if Gosu.button_down? Gosu::KB_UP or Gosu::button_down? Gosu::GP_BUTTON_0
            @player.accelerate
        end
        @player.move
        @player.collect_stars(@stars)

        if rand(100) < 2 and @stars.size < 10
            @stars.push(Star.new(@star_anim))
        end

        if rand(100) < 1 and @stars.size < 2
            @stars.push(Star.new(@star_anim))
        end
    end
  
    def draw
        @player.draw
        @background_image.draw(0, 0, 0)
        @stars.each { |star| 
        star.draw
        star.move
        }
        @bigs.each { |big| 
        big.draw
        big.move
        }
        @font.draw("Score: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
    end
  
    def button_down(id)
        if id == Gosu::KB_ESCAPE
            close
        else
            super
        end
    end
end

module ZOrder
    BACKGROUND, STARS, PLAYER, UI = *0..3
end

class Player
    attr_reader :score

    def initialize
        @image = Gosu::Image.new("media/carrot.png.png")
        @beep = Gosu::Sample.new("media/beep.wav")
        @x = @y = @vel_x = @vel_y = @angle = 0.0
        @score = 0
    end
    
    def warp (x, y)
        @x, @y = x, y
    end

    def go_left
        @x -= 4.5
    end

    def go_right
        @x += 4.5
    end

    def accelerate
        @vel_x += Gosu.offset_x(@angle, 1)
    end

    def move
        @x += @vel_x
        @x %= 640
        @y = 470

        @vel_x *= 0.95
        # @vel_y *= 0.95
    end

    def draw
        @image.draw_rot(@x, @y, 1, @angle)
    end

    def score
        @score
    end

    def collect_stars(stars)
        stars.reject! do |star|
            if Gosu.distance(@x, @y, star.x, star.y) < 35
                @score += 10
                @beep.play
                true
            else
                false
            end
        end
    end
end

class Star
    attr_reader :x, :y

    def initialize(animation)
        @animation = animation
        @x = rand * 640
        @y = 0
    end

    def move
        @y += 2
    end
    
    def draw
        img = @animation[Gosu.milliseconds / 100 % @animation.size]
        img.draw(@x - img.width / 2.0, @y - img.height / 2.0,
            ZOrder::STARS, 1, 1)
    end
end

class Big
    attr_reader :x, :y

    def initialize
        @image = Gosu::Image.new("media/berg.png")
        @x = rand * 640
        @y = 0
    end

    def move
        @y += 5
    end
    
    def draw
        @image.draw(@x, @y, ZOrder::STARS)    
    end
end

Tutorial.new.show
