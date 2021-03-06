require 'test_helper'

class Serialize::SettingsTest < ActiveSupport::TestCase

  def setup
    @settings = Serialize::Settings.new
  end

  test "should have default" do
    assert_equal 12, @settings.drug_font_size
    assert_equal "80mm", @settings.drug_width
    assert_equal "46mm", @settings.drug_height
  end

  test "should dump" do
    font_size = 16
    @settings.drug_font_size = font_size

    assert_equal(default_val.merge(drug_font_size: font_size),
      Serialize::Settings.dump(@settings))
  end

  test "should load" do
    font_size = 20
    drug_width = "20mm"

    @settings = Serialize::Settings.load(default_val.merge(
      drug_font_size: font_size,
      drug_width: drug_width
    ))

    assert_equal font_size, @settings.drug_font_size
    assert_equal drug_width, @settings.drug_width
    assert_equal "46mm", @settings.drug_height

  end

  private
    def default_val
      { drug_font_size: 12, drug_width: "80mm", drug_height: "46mm",
        appointment_font_size: 12, appointment_width: "80mm", appointment_height: "46mm" }
    end

end