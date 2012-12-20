#Clase State
class State
    def update
    end
    
    def draw
    end
    
    def state_change way
    end
end

#Clase GameObject
class GameObject
    attr_accessor :x, :y, :width, :height, :surface
    
    def initialize x, y, surface
        @x = x
        @y = y
        @surface = surface
        @width = surface.width
        @height = surface.height
    end
    
    def update
    end
    
    def draw screen
        @surface.blit screen, [@x, @y]
    end
    
    def handle_event event
    end
    
    def center_x w
        @x = w/2-@width/2
    end
    
    def center_y h
        @y = h/2-@height/2
    end
end

#Texto
class Text < GameObject
    def initialize x=0, y=0, text="Hola Mundo", size=48
        @font = Rubygame::TTF.new "media/font.ttf", size
        @text = text
        super x, y, rerender_text()
    end
    
    def rerender_text
        @width, @height = @font.size_text(@text)
        @surface = @font.render(@text, true, [255,255,255])
    end
    
    def text
        @text
    end
    
    def text= string
        @text = string
        rerender_text
    end
end

class Selector < GameObject
    attr_reader :choice
    def initialize choice, *texts
        @texts = texts
        @choice = choice
        @x = @x2 = 0
        @y = @texts[choice].y+3
        @speed = 10
        @left = Rubygame::Surface.new [5, 40]
        @right = Rubygame::Surface.new [5, 40]
        @left.fill [255, 255, 255]
        @right.fill [255, 255, 255]
        super x, y, @left
    end
    
    def update
        x_target = @texts[@choice].x-10
        x2_target = @texts[@choice].x+@texts[@choice].width+4
        y_target = @texts[@choice].y+3
        
        if @x != x_target and (@x-x_target).abs <= @speed
            @x = x_target
        elsif @x < x_target
            @x += @speed
        elsif @x > x_target
            @x -= @speed
        end
        
        if @x2 != x2_target and (@x2-x2_target).abs <= @speed
            @x2 = x2_target
        elsif @x2 < x2_target
            @x2 += @speed
        elsif @x2 > x2_target
            @x2 -= @speed
        end
        
        if @y != y_target and (@y-y_target).abs <= @speed
            @y = y_target
        elsif @y < y_target
            @y += @speed
        elsif @y > y_target
            @y -= @speed
        end
    end
    
    def draw screen
        @left.blit screen, [@x, @y]
        @right.blit screen, [@x2, @y]
    end
    
    def handle_event ev
        case ev
            when Rubygame::KeyDownEvent
                if ev.key == Rubygame::K_UP
                    unless @choice == 0
                        @choice -= 1
                    end
                end
                if ev.key == Rubygame::K_DOWN
                    unless @choice == @texts.length-1
                        @choice += 1
                    end
                end
        end
    end
end
