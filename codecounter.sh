#!/bin/bash
targetDir=$1
exclude=$(echo $2)
excludes=($(echo $exclude|sed 's,:,\n,g'))

cd $targetDir

languages=('sh' 'php' 'py' 'js' 'css');
i=0;
for language in "${languages[@]}"
do
  data=$(find -name "*."$language 2>/dev/null)
  for exclude in "${excludes[@]}"
  do
    data=$(echo $data|sed 's,\ ,\n,g'|grep -v ./$exclude)
  done
  if [ -z "$data" ]; then
    totals[$i]=$(echo 0)
  else
    total=$(wc -l $(echo $data|sed 's,\ ,\n,g')|grep total)
    if [ -z "$total" ]; then
      count=$(wc -l $(echo $data|sed 's,\ ,\n,g')|sed "s,$data,,g")
    else
      count=$(wc -l $(echo $data|sed 's,\ ,\n,g')|tail -n 1|sed -e 's,total,,g' -e 's,\ ,,g')
    fi
    totals[$i]=$(echo $count)
  fi
  i=$i+1
done

total=0
i=0;
for language in "${languages[@]}"
do
  total=$(($total+${totals[$i]}))
  if [ ${totals[$i]} != 0 ]; then
    echo $language: ${totals[$i]}
  fi
  i=$i+1
done
echo Total lines of code: $total