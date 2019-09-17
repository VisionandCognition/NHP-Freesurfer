#!/bin/bash
MONKEY=$1
atlasXML=${MONKEY}/D99_${MONKEY}.xml

touch ${atlasXML}
filename="../atlases/D99_atlas/D99_labeltable_reformat.txt"

echo '<?xml version="1.0" encoding="ISO-8859-1"?>' >> ${atlasXML}
echo '<atlas version="1.0">' >> ${atlasXML}
echo '  <header>' >> ${atlasXML}
echo '    <name>D99 in '${MONKEY}'</name>' >> ${atlasXML}
echo '    <shortname>D99'${MONKEY}'</shortname>' >> ${atlasXML}
echo '    <type>Label</type>' >> ${atlasXML}
echo '    <images>' >> ${atlasXML}
echo '      <imagefile>/D99_in_'${MONKEY}'</imagefile>' >> ${atlasXML}
echo '      <summaryimagefile>/D99_in_'${MONKEY}'</summaryimagefile>' >> ${atlasXML}
echo '    </images>' >> ${atlasXML}
echo '  </header>' >> ${atlasXML}
echo '  <data>' >> ${atlasXML}

while read -r line
do
    set $line
    LABLENUM=$1
    LABLENAME=$2
    echo "${MONKEY}: Getting center of gravity for $LABLENAME"
    xyz="$(fslstats ${MONKEY}/ROI/${LABLENAME}.nii.gz -C)"
    set -- $xyz
    x="$(python -c "print(round($1))")"
    y="$(python -c "print(round($2))")"
    z="$(python -c "print(round($3))")"
    echo '<label index="'${LABLENUM}'" x="'${x}'" y="'${y}'" z="'${z}'">'${LABLENAME}'</label>' >> ${atlasXML}
done < "$filename"

echo '  </data>' >> ${atlasXML}
echo '</atlas>' >> ${atlasXML}

