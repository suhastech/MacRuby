require File.expand_path('../../../../spec_helper', __FILE__)
require File.expand_path('../../fixtures/classes', __FILE__)
require File.expand_path('../shared/basic', __FILE__)
require File.expand_path('../shared/numeric_basic', __FILE__)
require File.expand_path('../shared/integer', __FILE__)

describe "Array#pack with format 'L'" do
  it_behaves_like :array_pack_basic, 'L'
  it_behaves_like :array_pack_basic_non_float, 'L'
  it_behaves_like :array_pack_arguments, 'L'
  it_behaves_like :array_pack_numeric_basic, 'L'
  it_behaves_like :array_pack_integer, 'L'
end

describe "Array#pack with format 'l'" do
  it_behaves_like :array_pack_basic, 'l'
  it_behaves_like :array_pack_basic_non_float, 'l'
  it_behaves_like :array_pack_arguments, 'l'
  it_behaves_like :array_pack_numeric_basic, 'l'
  it_behaves_like :array_pack_integer, 'l'
end

ruby_version_is "1.9.3" do
  describe "Array#pack with modifier '>'" do
    describe "with format 'L'" do
      it_behaves_like :array_pack_32bit_be, 'L>'
    end

    describe "with format 'l'" do
      it_behaves_like :array_pack_32bit_be, 'l>'
    end
  end

  describe "Array#pack with modifier '<'" do
    describe "with format 'L'" do
      it_behaves_like :array_pack_32bit_le, 'L<'
    end

    describe "with format 'l'" do
      it_behaves_like :array_pack_32bit_le, 'l<'
    end
  end
end

little_endian do
  describe "Array#pack with format 'L'" do
    it_behaves_like :array_pack_32bit_le, 'L'
  end

  describe "Array#pack with format 'l'" do
    it_behaves_like :array_pack_32bit_le, 'l'
  end

  platform_is :wordsize => 32 do
    describe "Array#pack with format 'L' with modifier '_'" do
      it_behaves_like :array_pack_32bit_le, 'L_'
    end

    describe "Array#pack with format 'L' with modifier '!'" do
      it_behaves_like :array_pack_32bit_le, 'L!'
    end

    describe "Array#pack with format 'l' with modifier '_'" do
      it_behaves_like :array_pack_32bit_le, 'l_'
    end

    describe "Array#pack with format 'l' with modifier '!'" do
      it_behaves_like :array_pack_32bit_le, 'l!'
    end
  end

  platform_is :wordsize => 64 do
    platform_is_not :os => :windows do
      describe "Array#pack with format 'L' with modifier '_'" do
        it_behaves_like :array_pack_64bit_le, 'L_'
      end

      describe "Array#pack with format 'L' with modifier '!'" do
        it_behaves_like :array_pack_64bit_le, 'L!'
      end

      describe "Array#pack with format 'l' with modifier '_'" do
        it_behaves_like :array_pack_64bit_le, 'l_'
      end

      describe "Array#pack with format 'l' with modifier '!'" do
        it_behaves_like :array_pack_64bit_le, 'l!'
      end
    end

    platform_is :os => :windows do
      not_compliant_on :jruby do
        describe "Array#pack with format 'L' with modifier '_'" do
          it_behaves_like :array_pack_32bit_le, 'L_'
        end

        describe "Array#pack with format 'L' with modifier '!'" do
          it_behaves_like :array_pack_32bit_le, 'L!'
        end

        describe "Array#pack with format 'l' with modifier '_'" do
          it_behaves_like :array_pack_32bit_le, 'l_'
        end

        describe "Array#pack with format 'l' with modifier '!'" do
          it_behaves_like :array_pack_32bit_le, 'l!'
        end
      end

      deviates_on :jruby do
        describe "Array#pack with format 'L' with modifier '_'" do
          it_behaves_like :array_pack_64bit_le, 'L_'
        end

        describe "Array#pack with format 'L' with modifier '!'" do
          it_behaves_like :array_pack_64bit_le, 'L!'
        end

        describe "Array#pack with format 'l' with modifier '_'" do
          it_behaves_like :array_pack_64bit_le, 'l_'
        end

        describe "Array#pack with format 'l' with modifier '!'" do
          it_behaves_like :array_pack_64bit_le, 'l!'
        end
      end
    end
  end
end

big_endian do
  describe "Array#pack with format 'L'" do
    it_behaves_like :array_pack_32bit_be, 'L'
  end

  describe "Array#pack with format 'l'" do
    it_behaves_like :array_pack_32bit_be, 'l'
  end

  platform_is :wordsize => 32 do
    describe "Array#pack with format 'L' with modifier '_'" do
      it_behaves_like :array_pack_32bit_be, 'L_'
    end

    describe "Array#pack with format 'L' with modifier '!'" do
      it_behaves_like :array_pack_32bit_be, 'L!'
    end

    describe "Array#pack with format 'l' with modifier '_'" do
      it_behaves_like :array_pack_32bit_be, 'l_'
    end

    describe "Array#pack with format 'l' with modifier '!'" do
      it_behaves_like :array_pack_32bit_be, 'l!'
    end
  end

  platform_is :wordsize => 64 do
    platform_is_not :os => :windows do
      describe "Array#pack with format 'L' with modifier '_'" do
        it_behaves_like :array_pack_64bit_be, 'L_'
      end

      describe "Array#pack with format 'L' with modifier '!'" do
        it_behaves_like :array_pack_64bit_be, 'L!'
      end

      describe "Array#pack with format 'l' with modifier '_'" do
        it_behaves_like :array_pack_64bit_be, 'l_'
      end

      describe "Array#pack with format 'l' with modifier '!'" do
        it_behaves_like :array_pack_64bit_be, 'l!'
      end
    end

    platform_is :os => :windows do
      not_compliant_on :jruby do
        describe "Array#pack with format 'L' with modifier '_'" do
          it_behaves_like :array_pack_32bit_be, 'L_'
        end

        describe "Array#pack with format 'L' with modifier '!'" do
          it_behaves_like :array_pack_32bit_be, 'L!'
        end

        describe "Array#pack with format 'l' with modifier '_'" do
          it_behaves_like :array_pack_32bit_be, 'l_'
        end

        describe "Array#pack with format 'l' with modifier '!'" do
          it_behaves_like :array_pack_32bit_be, 'l!'
        end
      end

      deviates_on :jruby do
        describe "Array#pack with format 'L' with modifier '_'" do
          it_behaves_like :array_pack_64bit_be, 'L_'
        end

        describe "Array#pack with format 'L' with modifier '!'" do
          it_behaves_like :array_pack_64bit_be, 'L!'
        end

        describe "Array#pack with format 'l' with modifier '_'" do
          it_behaves_like :array_pack_64bit_be, 'l_'
        end

        describe "Array#pack with format 'l' with modifier '!'" do
          it_behaves_like :array_pack_64bit_be, 'l!'
        end
      end
    end
  end
end
