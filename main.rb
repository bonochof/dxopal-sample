require 'dxopal'
include DXOpal

GROUND_Y = 400
Image.register(:player, 'images/player.png')
Image.register(:apple, 'images/apple.png')
Image.register(:bomb, 'images/bomb.png')

Sound.register(:get, 'sounds/get.wav')
Sound.register(:explosion, 'sounds/explosion.wav')

GAME_INFO = {
  scene: :title,
  score: 0,
}

class Player < Sprite
  def initialize
    x = Window.width / 2
    y = GROUND_Y - Image[:player].height
    image = Image[:player]
    super(x, y, image)
    self.collision = [image.width / 2, image.height / 2, 16]
  end
  
  def update
    if Input.key_down?(K_LEFT) and x > 0
      self.x -= 8
    elsif Input.key_down?(K_RIGHT) and x < (Window.width - Image[:player].width)
      self.x += 8
    end
  end
end

class Item < Sprite
  def initialize (image)
    x = rand(Window.width - image.width)
    y = 0
    super(x, y, image)
    @speed_y = rand(9) + 4
  end
  
  def update
    self.y += @speed_y
    self.vanish if self.y > Window.height
  end
end

class Apple < Item
  def initialize
    super(Image[:apple])
    self.collision = [image.width / 2, image.height / 2, 56]
  end
  
  def hit
    Sound[:get].play
    self.vanish
    GAME_INFO[:score] += 10
  end
end

class Bomb < Item
  def initialize
    super(Image[:bomb])
    self.collision = [image.width / 2, image.height / 2, 42]
  end
  
  def hit
    Sound[:explosion].play
    self.vanish
    GAME_INFO[:scene] = :game_over
  end
end

class Items
  N = 5
  
  def initialize
    @items = []
  end
  
  def update (player)
    @items.each do |item|
      item.update(player)
    end
    
    Sprite.check(player, @items)
    Sprite.clean(@items)
    
    (N - @items.size).times do
      if rand(1..100) < 40
        @items.push(Apple.new)
      else
        @items.push(Bomb.new)
      end
    end
  end
  
  def draw
    Sprite.draw(@items)
  end
end

Window.load_resources do
  player = Player.new
  items = Items.new
  
  Window.loop do
    Window.draw_box_fill(0, 0, Window.width, GROUND_Y, [128, 255, 255])
    Window.draw_box_fill(0, GROUND_Y, Window.width, Window.height, [0, 128, 0])
    Window.draw_font(0, 0, "SCORE: #{GAME_INFO[:score]}", Font.default, :color=>[0, 0, 0])
    
    case GAME_INFO[:scene]
    when :title
      Window.draw_font(240, 120, "PRESS SPACE", Font.default, :color=>[200, 0, 0])
      GAME_INFO[:scene] = :playing if Input.key_push?(K_SPACE)
    when :playing
      player.update
      items.update(player)
      player.draw
      items.draw
    when :game_over
      player.draw
      items.draw
      Window.draw_font(240, 120, "PRESS SPACE", Font.default, :color=>[200, 0, 0])
      if Input.key_push?(K_SPACE)
        player = Player.new
        items = Items.new
        GAME_INFO[:score] = 0
        GAME_INFO[:scene] = :playing
      end
    end
  end
end
