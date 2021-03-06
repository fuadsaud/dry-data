module Dry
  module Data
    COERCIBLE = {
      string: String,
      int: Integer,
      float: Float,
      decimal: BigDecimal,
      array: Array,
      hash: Hash
    }.freeze

    NON_COERCIBLE = {
      nil: NilClass,
      symbol: Symbol,
      class: Class,
      true: TrueClass,
      false: FalseClass,
      date: Date,
      date_time: DateTime,
      time: Time
    }.freeze

    ALL_PRIMITIVES = COERCIBLE.merge(NON_COERCIBLE).freeze

    # Register built-in primitive types with kernel coercion methods
    COERCIBLE.each do |name, primitive|
      register(
        "coercible.#{name}",
        Type[primitive].new(Kernel.method(primitive.name), primitive)
      )
    end

    # Register built-in types that are non-coercible through kernel methods
    ALL_PRIMITIVES.each do |name, primitive|
      register(
        "strict.#{name}",
        Type[primitive].new(Type.method(:strict_constructor).to_proc.curry.(primitive), primitive)
      )
    end

    # Register built-in types that are non-coercible through kernel methods
    ALL_PRIMITIVES.each do |name, primitive|
      register(
        name.to_s,
        Type[primitive].new(Type.method(:passthrough_constructor), primitive)
      )
    end

    # Register non-coercible maybe types
    ALL_PRIMITIVES.each do |name, primitive|
      next if name == :nil
      register("maybe.strict.#{name}", self["strict.#{name}"].optional)
    end

    # Register coercible maybe types
    COERCIBLE.each do |name, primitive|
      register("maybe.coercible.#{name}", self["coercible.#{name}"].optional)
    end

    # Register :bool since it's common and not a built-in Ruby type :(
    register("bool", self["true"] | self["false"])
    register("strict.bool", self["strict.true"] | self["strict.false"])
  end
end

require 'dry/data/types/form'
