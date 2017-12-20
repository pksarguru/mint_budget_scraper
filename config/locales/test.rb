n = 0

indexarray = []

# @numbers = [1, 1, 2, 1, 4]
while n < @numbers.length
  a = 1

  i = 1

  while (n+i) < @numbers.length
    # 4 < 5
    if @numbers[n] == @numbers[n+i]
      # 1 == 4
      a += 1
      # a = 3
    end

    i += 1
    # i = 4
  end

  indexarray.push(a)

  n += 1
end
indexmax = indexarray.max
# indexarray = [3, 3, 1, 3, 1]
# indexmax = 3

whereismax = 0

while whereismax < indexarray.length
  if indexmax == indexarray[whereismax]
    @mode = @numbers[whereismax]
    whereismax = indexarray.length
  else
    whereismax += 1
  end
end

@mode = @numbers[whereismax]
