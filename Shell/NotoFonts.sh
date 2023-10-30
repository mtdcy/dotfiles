#!/bin/bash 
#
# download noto-cjk fonts 
#
# https://github.com/notofonts/noto-cjk/blob/main/Sans/README.md
# https://github.com/notofonts/noto-cjk/blob/main/Serif/README.md
#
# JP -> Japanese
# KR -> Korean
# SC -> Simplified Chinese
# TC -> Traditional Chinese
# HK -> Hong Kong

format=${1:-otf}

echo "download $format fonts..."

fonts=(Sans Serif)

urls=(
'https://github.com/googlefonts/noto-cjk/raw/main/$type/Variable/OTC/NotoSansCJK-VF.$format.ttc'
'https://github.com/googlefonts/noto-cjk/raw/main/$type/Variable/OTF/NotoSansCJKsc-VF.$format'
'https://github.com/googlefonts/noto-cjk/raw/main/$type/Variable/OTF/NotoSansCJKtc-VF.$format'
'https://github.com/googlefonts/noto-cjk/raw/main/$type/Variable/OTF/NotoSansCJKhk-VF.$format'
)

urls_mono=(
'https://github.com/googlefonts/noto-cjk/raw/main/Sans/Variable/OTC/NotoSansMonoCJK-VF.$format.ttc'
'https://github.com/googlefonts/noto-cjk/raw/main/Sans/Variable/OTF/Mono/NotoSansMonoCJKsc-VF.$format'
'https://github.com/googlefonts/noto-cjk/raw/main/Sans/Variable/OTF/Mono/NotoSansMonoCJKtc-VF.$format'
'https://github.com/googlefonts/noto-cjk/raw/main/Sans/Variable/OTF/Mono/NotoSansMonoCJKhk-VF.$format'
)

# Last-modified missing in some files
#opts="-N -q"
opts="-nc -q"

for type in ${fonts[@]}; do
    for url in ${urls[@]}; do
        eval -- echo "download font $url..." 
        eval -- wget $opts $url 
    done
done

for url in ${urls_mono[@]}; do
    eval -- echo "download mono font $url..." 
    eval -- wget $opts $url 
done
