#! /usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'rubygame'
require 'aliens'
require 'gun'
require 'bullet'

class Piece
  def initialize(resource, x=0, y=0)
    @surface = Rubygame::Surface.load(resource)
    update(x,y)
  end
  
  def blit(screen)
    @surface.blit(screen,[@x, @y])
  end

  def update(x, y)
    x, y = transform(x,y)
    @x = x
    @y = y
  end

  def transform(x, y)
    return x + 387, -y + 500
  end
end

class AlienPiece < Piece
  def initialize(x, y)
    super("resource/image/alien-0.png", x, y)
  end
end

class GunPiece < Piece
  def initialize(x, y)
    super("resource/image/gun.png", x, y)
  end
end

class BulletPiece < Piece
  def initialize(x, y)
    super("resource/image/bullet.png", x, y)
  end
end

class NullPiece < Piece
  def update(x,y)
    # do nothing
  end
end

class GuiView
  include Rubygame
  
  def initialize()
    @screen = Screen.new [775, 572]
    @background = Surface.load("resource/image/background.png")
    @events = EventQueue.new
    @pieces = {}
  end

  def addPiece(id, piece)
    @pieces[id] = piece
  end
  
  def addAlien(alien)
    piece = AlienPiece.new(alien.location.x, alien.location.y)
    self.addPiece(alien.id, piece)
  end

  def addGun(gun)
    piece = GunPiece.new(gun.location.x, gun.location.y)
    self.addPiece(gun.id, piece)
  end
  
  def addBullet(bullet)
    piece = BulletPiece.new(bullet.location.x, bullet.location.y)
    self.addPiece(bullet.id, piece)
  end

  def move(event)
    piece = @pieces[event.id] || NullPiece
    piece.update(event.location.x, event.location.y)
  end

  def notify(event)
    @events.post(event)
  end

  def eventLoop()
    self.addAlien(Alien.new({:location => Vector.new(0, 500)}))
    self.addGun(Gun.new({:location => Vector.new(0,0)}))
    bullet = Bullet.new({:location => Vector.new(0,10)})
    self.addBullet(bullet)
    bullet.addObserver(self)
    loop do
      bullet.move()
      @events.each do |event|
        case event
        when QuitEvent
          return
        when Moved
          move(event)
        end
      end
      draw
    end
  end

  def draw()
    @background.blit(@screen, [0,0])
    @pieces.each_value {|piece| piece.blit(@screen)}
    @screen.update
  end
end

Rubygame.init
GuiView.new.eventLoop
Rubygame.quit
