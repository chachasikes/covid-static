#!/bin/bash
headers="id,git_industry_category_key,git_pdf_template_type,git_filepath,git_filename,git_publishing_status,git_date_updated,git_commit_author,git_commit_subject,github_url,git_permalink,git_download_url,git_pdf_language,git_type_document,git_commit_hash,git_commit_hash_abbreviated,git_repository,git_change_type"
repo="https://github.com/cagov/covid-static/"
filename="./history/csv/pdf-history.csv"
rm -rf ${filename}
touch ${filename}
echo ${headers} >> ${filename}
startCommit="master"
folder="pdf"
public_url="https://files.covid19.ca.gov/pdf/"
echo "Total Commits"
git log --pretty=format:'' | wc -l
IFS=',' read -r -a headersArray <<< "$headers"
# --diff-filter=ACDMRT # https://git-scm.com/docs/git-log
# git log master --pretty=format: --name-only --all --full-history --diff-filter=D -- pdf*uidance* pdf*hecklist* | sort - | sed '/^$/d'
#for file in $(git log ${startCommit} --pretty=format: --name-only --all --full-history --diff-filter=A -- ${folder}*uidance* ${folder}*hecklist* | sort - | sed '/^$/d');

get_history () {
type_change=$1
for file in $(git log ${startCommit} --pretty=format: --name-only --diff-filter=${type_change} --all --full-history -- ${folder}*uidance* ${folder}*hecklist* | sort - | sed '/^$/d');
do
    # echo ${file}
    # for response in $git_response;
    # do
    #     type_change=${response[0]}
    #     file=${response[1]}
    # done


    formatString=""
    for i in "${headersArray[@]}"
    do
        # echo $i
        if [[ $i == "github_url" ]]
            then
                formatString+="${repo}blob/%H/${file},"
        elif [[ $i == "git_download_url" ]]
            then
                formatString+="${repo}raw/%H/${file},"
        elif [[ $i == "git_permalink" ]]
            then
                filestring=${file//pdf\//}
                formatString+="${public_url}${filestring},"
        elif [ $i == "git_industry_category_key" ];
            then
            if [[ $file =~ .*"hecklist".* ]];
                then
                odi_industry_category_key=${file//pdf\/checklist-/}
                odi_industry_category_key=${odi_industry_category_key//.pdf/}
                odi_industry_category_key=${odi_industry_category_key//.PDF/}
                odi_industry_category_key=${odi_industry_category_key//--ar/}
                odi_industry_category_key=${odi_industry_category_key//--en/}
                odi_industry_category_key=${odi_industry_category_key//--es/}
                odi_industry_category_key=${odi_industry_category_key//--hmn/}
                odi_industry_category_key=${odi_industry_category_key//--hy/}
                odi_industry_category_key=${odi_industry_category_key//--km/}
                odi_industry_category_key=${odi_industry_category_key//--ko/}
                odi_industry_category_key=${odi_industry_category_key//--ru/}
                odi_industry_category_key=${odi_industry_category_key//--th/}
                odi_industry_category_key=${odi_industry_category_key//--tl/}
                odi_industry_category_key=${odi_industry_category_key//--vi/}
                odi_industry_category_key=${odi_industry_category_key//--zh-tw/}
                odi_industry_category_key=${odi_industry_category_key//--zh-hans/}
                odi_industry_category_key=${odi_industry_category_key//--zh-cn/}


                formatString+="\"${odi_industry_category_key}\","
            else
                formatString+="General,"
            fi
        elif [ $i == "git_filename" ];
            then
            filestring=${file//pdf\//}
            formatString+="${filestring},"
        elif [ $i == "git_date_updated" ];
            then
            formatString+="\"%ad\","
        elif [ $i == "git_commit_author" ];
            then
            formatString+="%an,"
        elif [ $i == "git_pdf_template_type" ];
            then
            if [[ "$file" == *"immigrant_guidance"* ]];
                then
                # echo "found"
                formatString+="General-IG,"
            elif [[ "$file" == *"great-plates"* ]];
                then
                # echo "found"
                formatString+="General-GP,"
            elif [[ "$file" =~ ."hecklist".* ]];
                then
                formatString+="Checklist,"
            elif [[ "$file" =~ ."uidance".* ]];
                then
                formatString+="Guidance,"
            else
                formatString+="General,"
            fi
        elif [ $i == "git_pdf_language" ];
            then
            if [[ $file =~ .*"-ko".* ]] || [[ $file =~ .*"_Korean".*  ]];
                then
                formatString+="Korean,"
            elif [[ $file =~ .*"-Vietnamese".* ]] || [[ $file =~ .*"-vi".* ]];
                then
                formatString+="Vietnamese,"
            elif [[ $file =~ .*"-pa".* ]] || [[ $file =~ .*"_Punjabi".* ]];
                then
                formatString+="Punjabi,"
            elif [[ $file =~ .*"-ar".* ]] || [[ $file =~ .*"_Arabic".* ]];
                then
                formatString+="Arabic,"
            elif [[ $file =~ .*"-zh-Hans".* ]] || [[ $file =~ .*"-zh-ch".* ]] || [[ $file =~ .*"-zh-hans".* ]] || [[ $file =~ .*"_CH_Simplified".* ]];
                then
                formatString+="Chinese%20Simplified,"
            elif [[ $file =~ .*"-zh-hant".* ]] || [[ $file =~ .*"-zh-Hant".*  ]] || [[ $file =~ .*"-zh-tw".*  ]];
                then
                formatString+="Chinese%20Traditional,"
            elif [[ $file =~ .*"_Tagalog".*  ]] || [[ $file =~ .*"-tl".*  ]];
                then
                formatString+="Tagalog,"
            elif [[ $file =~ .*"--th".*  ]];
                then
                formatString+="Thai,"
            elif [[ $file =~ .*"--ru".*  ]];
                then
                formatString+="Russian,"
            elif [[ $file =~ .*"--km".*  ]];
                then
                formatString+="Khmer,"
            elif [[ $file =~ .*"--hmn".*  ]];
                then
                formatString+="Hmong,"
            elif [[ $file =~ .*"_Spanish".*  ]] || [[ $file =~ .*"-es".*  ]];
                then
                formatString+="Spanish,"
            elif [[ $file =~ .*"_Armenian".*  ]] || [[ $file =~ .*"-hy".*  ]];
                then
                formatString+="Armenian,"
            elif [[ $file =~ .*"_Cambodian".*  ]] || [[ $file =~ .*"-km".*  ]];
                then
                formatString+="Cambodian,"
            else
                formatString+="English,"
            fi
        elif [ $i == "git_commit_subject" ];
            then
            formatString+="\"%s\","
        elif [ $i == "git_type_document" ];
            then
            formatString+="PDF,"
        elif [ $i == "git_publishing_status" ];
            then
            formatString+="\"Git%20history\","
        elif [ $i == "git_filepath" ];
            then
            formatString+="${file},"
        elif [ $i == "git_change_type" ];
            then
            if [[ $type_change == "A" ]]
                then
                    formatString+="Added,"
            elif [[ $type_change == "D" ]]
                then
                    formatString+="Deleted,"
            elif [[ $type_change == "M" ]]
                then
                    formatString+="Modified,"
            fi
        elif [ $i == "git_repository" ];
            then
            formatString+="${repo},"
        elif [ $i == "git_commit_hash" ];
            then
            formatString+="\"%H\","
        elif [ $i == "git_commit_hash_abbreviated" ];
            then
            formatString+="\"%h\","
        else
            formatString+=","
        fi
    done
    # echo ${formatString}
    git log --date=iso --format=${formatString} --all --full-history --diff-filter=${type_change} --no-merges -- ${file} >> ${filename}
done
}

# Run through the different types of commits we want to store
# Select only files that are Added (A), Copied (C), Deleted (D), Modified (M), Renamed (R), have their type (i.e. regular file, symlink, submodule, …​) changed (T), are Unmerged (U), are Unknown (X), or have had their pairing Broken (B).
get_history A
get_history C
get_history D
get_history M
get_history R
get_history X
get_history B
