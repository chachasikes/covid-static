#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const moment = require('moment');
PDFParser = require("pdf2json")

console.log('Extracting Markdown from .pdf files in directory');
let inputFolderPath = "./";
let outputFolderPath = "./markdown-experimental";

const getAllFiles = (dirPath, arrayOfFiles) => {
  const files = fs.readdirSync(dirPath);
  arrayOfFiles = arrayOfFiles || []
  files.forEach(file => {
    if (fs.statSync(dirPath + "/" + file).isDirectory()) {
      arrayOfFiles = getAllFiles(dirPath + "/" + file, arrayOfFiles)
    } else {
      arrayOfFiles.push(path.join(dirPath, "/", file))
    }
  })
  return arrayOfFiles
}

// Read all the files
const files = fs.readdirSync(inputFolderPath);
let arrayOfFiles = [];
files.forEach(file => {
    if (fs.statSync(inputFolderPath + "/" + file).isDirectory()) {
      arrayOfFiles = getAllFiles(inputFolderPath + "/" + file, arrayOfFiles)
    } else {
      arrayOfFiles.push(path.join(inputFolderPath, "/", file))
    }
});

// Get specific types of PDFs.
// console.log(arrayOfFiles);
let checklistFiles = arrayOfFiles.filter((file) => {
  return file.includes('checklist-');
});

checklistFiles = checklistFiles.slice(0,3); // Sample
// console.log(checklistFiles);

// Read all files of a specific type.
checklistFiles.forEach(checklistFile => {
  // Create a pdf parser.
  let pdfParser = new PDFParser(this,1);
  // Load the file.
  pdfParser.loadPDF(`${inputFolderPath}/${checklistFile}`);
  pdfParser.on("pdfParser_dataError", errData => console.error(errData.parserError) );
  pdfParser.on("pdfParser_dataReady", pdfData => {
    // console.log(pdfData)
    // Read file contents and build plain text file as markdown.
    // Pass the file a custom formatter for the raw text.
    let markdownDoc = getMarkdown({formatter: formatterChecklist, pdfParser});
    console.log(markdownDoc);

    let markdownFileName = checklistFile.replace(/.pdf/i, '.md');
    // console.log(markdownFileName);
    fs.writeFile(`${outputFolderPath}/${markdownFileName}`, markdownDoc, err => {if (err) console.error(err); else console.log('file created.');});

    return;

  });
})

const formatterChecklist = (text) => {
  text = text.replace(//g, "▢");
  return text;
}

let guidanceFiles = arrayOfFiles.filter((file) => {
  return file.includes('guidance-');
});
// console.log(guidanceFiles);

const getMarkdown = ({formatter = null, pdfParser}) => {
  // Process date
  let createdDateString = pdfParser.PDFJS.documentInfo.CreationDate;
  let modDateString = pdfParser.PDFJS.documentInfo.CreationDate;
  let createdDate = createdDateString.replace('D:', '').substring(0,14);
  let modDate = createdDateString.replace('D:', '').substring(0,14);
  let createdDateFormatted = moment(createdDate, "YYYYMMDDHHmmSS");
  let modDateFormatted = moment(createdDate, "YYYYMMDDHHmmSS");

  // Create a plain text file as markdown, with frontmatter attributes derived from this file.
  let doc = ['---'];
  Object.keys(pdfParser.PDFJS.documentInfo).map(item => {
      doc.push(`${item}: ${pdfParser.PDFJS.documentInfo[item]}`)
  });

  doc.push(`date_created: ${createdDateFormatted}`);
  doc.push(`date_modified: ${modDateFormatted}`);
  doc.push('---');

  let rawTextParsed = pdfParser.getRawTextContent();

  // Transformations
  if (formatter !== null) {
    try {
      formatter(rawTextParsed);
    } catch (error) {
      console.error('formatter not fonud');
    }
  }
  
  doc.push(rawTextParsed);
  let markdownDoc = doc.join('\n');
  return markdownDoc;
}










// didn't work
// pdfParser.on("pdfParser_dataReady", pdfData => {
//     fs.writeFile(`${outputFolderPath}/checklist-agriculture--en.json`, JSON.stringify(pdfData));
// });

// let rawText = textbody.join(' ');
// let replaceCheckbox = rawText.replace(/ï¿/gi, '&#9744;'); //▢
// console.log(replaceCheckbox);

// Title: 'COVID19 Agriculture and Livestock Checklist',
// Author: 'State of California',
// Subject: 'COVID-19 Industry Guidance - Car Dealerships and Rental Operators',
// Keywords: 'COVID-19, checklist coronavirus, Agriculture and Livestock',
// Creator: 'Microsoft® Word 2016',
// Producer: 'Microsoft® Word 2016',
// CreationDate: "D:20200702135430-07'00'",
// ModDate: "D:20200702135430-07'00'"

// let textbody = [];

// pdfParser.PDFJS.pages.map((page) => {
//     page.Texts.map((text) => {
//         try {
//             let string = unescape(text.R[0].T);
//             textbody.push(string);
//         } catch (err) {

//         }
//     });
// });