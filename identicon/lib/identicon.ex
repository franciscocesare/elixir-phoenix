defmodule Identicon do

  @doc """

  ## Examples

      iex> Identicon.main("banana")
      [114, 179, 2, 191, 41, 122, 34, 138, 117, 115, 1, 35, 239, 239, 124, 65]

  """

  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_pair_numbers
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_code, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}

      {top_left, bottom_right}
    end

    %Identicon.Image{image | pixel_map: pixel_map}

  end

  def filter_pair_numbers (%Identicon.Image{grid: grid} = image)do
    grid = Enum.filter grid, fn({code, _index}) ->
      rem(code, 2) == 0
    end

    %Identicon.Image{image | grid: grid}
  end

  def build_grid(%Identicon.Image{hex: hex} = image) do
  grid =   hex
  |> Enum.chunk(3)  #chunck is deprecated, pero me tiraba error con chunck_every
  |> Enum.map(&mirror_row/1)
  |> List.flatten
  |> Enum.with_index

  %Identicon.Image{image | grid: grid}
  end

  # IN [145, 46, 200]
  # OUT [145, 46, 200, 46, 145]
  def mirror_row(row) do

    [first, second | _tail ] = row
    row ++ [second, first]
  end

  @doc """
  Select values of RGB
   %Identicon.Image{hex: [r, g, b | _tail]} = image REFACT, PASO ESTO DIRECTO AL ARG QUE RECIBE, QUE ERA IMAGE ANTES
    vamos a tener acceso a las tres primeras numeros de la struct

    En JS seria algo asi:
    pick_color: function(image){
      image.color = {
        r : image.hex[0],
        g : image.hex[1],
        b : image.hex[2],
      };
      return image
    }
  """
  def pick_color(%Identicon.Image{hex: [r, g, b | _tail]} = image) do

    %Identicon.Image{image | color: {r, g, b}}


  end

  def hash_input(input) do
    hex =:crypto.hash(:md5, input)
      |> :binary.bin_to_list()

    %Identicon.Image{hex: hex}

  end
end
