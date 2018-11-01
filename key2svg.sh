#!/bin/sh

KEY=$(realpath "$1")
DIR=$(dirname "$KEY")

PDF=`cat <<EOF | osascript - "$KEY"
property exportFileExtension : "pdf"
property useEncryptionDefaultValue : false

on run argv
	-- THE DESTINATION FOLDER 
	-- (see the "path" to command in the Standard Additions dictionary for other locations, such as movies folder, pictures folder, desktop folder)
	set the defaultDestinationFolder to (path to documents folder)
	-- set the defaultDestinationFolder to (item 2 of argv)
	
	tell application "Keynote"
		activate
		open item 1 of argv
	end tell
	
	set usePDFEncryption to useEncryptionDefaultValue
	tell application "Keynote"
		activate
		try
			if playing is true then tell the front document to stop
			
			if not (exists document 1) then error number -128
			
			if usePDFEncryption is true then
				-- PROMPT FOR PASSWORD (OPTIONAL)
				repeat
					display dialog "Enter a password for the PDF file:" default answer ¬
						"" buttons {"Cancel", "No Password", "OK"} ¬
						default button 3 with hidden answer
					copy the result to ¬
						{button returned:buttonPressed, text returned:firstPassword}
					if buttonPressed is "No Password" then
						set usePDFEncryption to false
						exit repeat
					else
						display dialog "Enter the password again:" default answer ¬
							"" buttons {"Cancel", "No Password", "OK"} ¬
							default button 3 with hidden answer
						copy the result to ¬
							{button returned:buttonPressed, text returned:secondPassword}
						if buttonPressed is "No Password" then
							set usePDFEncryption to false
							exit repeat
						else
							if firstPassword is not secondPassword then
								display dialog "Passwords do no match." buttons ¬
									{"Cancel", "Try Again"} default button 2
							else
								set providedPassword to the firstPassword
								set usePDFEncryption to true
								exit repeat
							end if
						end if
					end if
				end repeat
			end if
			
			-- DERIVE NAME AND FILE PATH FOR NEW EXPORT FILE
			set documentName to the name of the front document
			if documentName ends with ".key" then ¬
				set documentName to text 1 thru -5 of documentName
			
			tell application "Finder"
				set exportItemFileName to documentName & "." & exportFileExtension
				set incrementIndex to 1
				repeat until not (exists document file exportItemFileName of defaultDestinationFolder)
					set exportItemFileName to ¬
						documentName & "-" & (incrementIndex as string) & "." & exportFileExtension
					set incrementIndex to incrementIndex + 1
				end repeat
			end tell
			set the targetFileHFSPath to (defaultDestinationFolder as string) & exportItemFileName
			
			-- EXPORT THE DOCUMENT
			with timeout of 1200 seconds
				if usePDFEncryption is true then
					export front document to file targetFileHFSPath ¬
						as PDF with properties {password:providedPassword}
				else
					export front document to file targetFileHFSPath as PDF
				end if
			end timeout
			
		on error errorMessage number errorNumber
			if errorNumber is not -128 then
				display alert "EXPORT PROBLEM" message errorMessage
			end if
			error number -128
		end try
    
    close front document
	end tell
	
	return POSIX path of targetFileHFSPath
  end run
EOF`

BASENAME=$(basename "$PDF" .pdf)
BASEDIR=$(dirname "$PDF")
echo "$BASEDIR/$BASENAME"
pdfseparate "$PDF" "$BASEDIR/$BASENAME-%d.pdf"
for f in "$BASEDIR/$BASENAME-"*.pdf; do
  echo "File -> $f"
  BASEPAGE=$(basename "$f" .pdf)
  gs -o "$BASEDIR/$BASEPAGE-plain.pdf"  -dNoOutputFonts -sDEVICE=pdfwrite "$f"
  /usr/local/bin/inkscape -z "$BASEDIR/$BASEPAGE-plain.pdf" -l "$BASEDIR/$BASEPAGE.svg"
  rm "$BASEDIR/$BASEPAGE-plain.pdf" "$f"
  mv "$BASEDIR/$BASEPAGE.svg" "$DIR"
done
rm "$PDF"