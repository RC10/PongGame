class InGame < State
    @@music = Rubygame::Music.load("media/background.ogg")
    
    def initialize game
        @game = game
        @screen = game.screen
        @queue = game.queue
        
        limit = @screen.height - 10
        player_score_x = @screen.width * 0.20 #128
        enemy_score_x = @screen.width * 0.70 #448
        @player = Paddle.new 50, 10, player_score_x, 35, Rubygame::K_W, Rubygame::K_S, 10, limit
        @enemy = Paddle.new @screen.width-50-@player.width, 10, enemy_score_x, 35, Rubygame::K_UP, Rubygame::K_DOWN, 10, limit
        @player.center_y @screen.height
        @enemy.center_y @screen.height
        @ball = Ball.new @screen.width/2, @screen.height/2
        @won = false
        
        @win_text = Text.new
        @play_again_text = Text.new 0, 0, "Otra Partida? Pulsa Y o N", 40
        @background = Background.new @screen.width, @screen.height
    end
    
    #Como se indica una victoria
    def win player
        if player == 1
            @win_text.text = "El jugador 1 gana!"
        elsif player == 2
            @win_text.text = "El jugador 2 gana!"
        end
        @won = true
        @win_text.center_x @screen.width
        @win_text.center_y @screen.height
        @play_again_text.center_x @screen.width
        @play_again_text.y = @win_text.y+60
    end
    
    def update
        @player.update
        @enemy.update
        @ball.update @screen, @player, @enemy unless @won
        
        if @player.score == Conf[:winning_score]
            win 1
        elsif @enemy.score == Conf[:winning_score]
            win 2
        end
        
        @queue.each do |ev|
            @player.handle_event ev
            @enemy.handle_event ev
            case ev
                when Rubygame::KeyDownEvent 
                    if ev.key == Rubygame::K_Y and @won #Volvemos a empezar
                        @player.center_y @screen.height
                        @enemy.center_y @screen.height
                        @player.score = 0
                        @enemy.score = 0
                        @won = false
                    end
                    if ev.key == Rubygame::K_N and @won
                        @game.switch_state Title.new(@game)
                    end
                    if ev.key == Rubygame::K_P and !@won #Pausa
                        @game.switch_state Pause.new(@game, self)
                    end
                    if ev.key == Rubygame::K_ESCAPE
                        @game.switch_state Title.new(@game)
                    end
            end
        end
        
        if collision? @ball, @player
            @ball.collision @player, @screen
        elsif collision? @ball, @enemy
            @ball.collision @enemy, @screen
        end
        
    end
    
    def draw
        @screen.fill [0,0,0]
        
        unless @won
            @background.draw @screen
            @player.draw @screen
            @enemy.draw @screen
            @ball.draw @screen
        else
            @win_text.draw @screen
            @play_again_text.draw @screen
        end
        
        @screen.flip
    end
    
    def collision? obj1, obj2
        if obj1.y + obj1.height < obj2.y
            return false
        end
        if obj1.y > obj2.y + obj2.height
            return false
        end
        if obj1.x + obj1.width < obj2.x
            return false
        end
        if obj1.x > obj2.x + obj2.width
            return false
        end
        return true
    end
    
    def state_change way
        if Conf[:music]
            if way == :going_out
                @@music.Pause
            else
                if @@music.paused?
                    @@music.unpause
                else
                    @@music.play :repeats => -1
                end
            end
        end
    end
end

#Paddle class (Los jugadores)
class Paddle < GameObject
    def initialize x, y, score_x, score_y, up_key, down_key, top_limit, bottom_limit
        surface = Rubygame::Surface.new [20, 100]
        surface.fill [255,255,255]
        @up_key = up_key
        @down_key = down_key
        @moving_up = false
        @moving_down = false
        @top_limit = top_limit
        @bottom_limit = bottom_limit
        
        @score = 0
        @score_text = Text.new score_x, score_y, @score.to_s, 100
        
        super x, y, surface
    end
    
    def center_y h
        @y = h/2-@height/2
    end
    
    def handle_event event
        case event
            when Rubygame::KeyDownEvent
                if event.key == @up_key
                    @moving_up = true
                elsif event.key == @down_key
                    @moving_down = true
                end
            when Rubygame::KeyUpEvent
                if event.key == @up_key
                    @moving_up = false
                elsif event.key == @down_key
                    @moving_down = false
                end
        end
    end
    
    def update
        if @moving_up and @y > @top_limit
            @y -= 5
        end
        if @moving_down and @y+@height < @bottom_limit
            @y += 5
        end
    end
    
    def score
        @score
    end
    
    def score= num
        @score = num
        @score_text.text = num.to_s
    end
    
    def draw screen
        super
        @score_text.draw screen
    end
end

#Background class (El fondo)
class Background < GameObject
    def initialize width, height
        surface = Rubygame::Surface.new [width, height]
        
        #Se dibuja el fondo
        white = [255, 255, 255]
        
        surface.draw_box_s [0,0], [surface.width, 10], white #Parte alta
        surface.draw_box_s [0,0], [10, surface.height], white #Izquierda
        surface.draw_box_s [0,surface.height-10], [surface.width, surface.height], white #Parte baja
        surface.draw_box_s [surface.width-10,0], [surface.width, surface.height], white #Derecha
        surface.draw_box_s [surface.width/2-5,0], [surface.width/2+5, surface.height], white #Linea divisoria
        
        super 0, 0, surface
    end
end

#La pelota
class Ball < GameObject
    def initialize x, y
        @surface = Rubygame::Surface.load "media/ball.png"
        @vx = @vy = Conf[:ball_speed]
        @hit_sound = Rubygame::Sound.load("media/pop.ogg")
        super x, y, surface
    end
    
    def update screen, player, enemy
        @x += @vx
        @y += @vy
        
        #Izquierda (Punto para el enemigo)
        if @x <= 10
            enemy.score += 1
            score screen
        end
        
        #Derecha (Punto para el jugador)
        if @x+@width >= screen.width-10
            player.score += 1
            score screen
        end
        
        #Arriba o Abajo
        if @y <= 10 or @y+@height >= screen.height-10
            @vy *= -1
            @hit_sound.play if Conf[:fx]
        end
    end
    
    def score screen
        @vx *= -1
        @x = screen.width/4 + rand(screen.width/2) #La bola vuelve al centro
        @y = rand(screen.height-50)+25 #Reaparece en una posicion del eje y
    end
    
    def collision paddle, screen
        #Vemos si se ha tocado el jugador de la izquierda
        if paddle.x < screen.width/2 #detras del jugador
            unless @x < paddle.x-5
                @x = paddle.x+paddle.width+1
                @vx *= -1
                @hit_sound.play if Conf[:fx]
            end
            #Ahora el lado derecho
        else
            unless @x > paddle.x-5
                @x = paddle.x-@width-1
                @vx *= -1
                @hit_sound.play if Conf[:fx]
            end
        end
    end
end
