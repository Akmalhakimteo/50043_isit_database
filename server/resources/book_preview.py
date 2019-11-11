from flask import render_template, make_response, request
from flask_restful import Resource, reqparse
from common.util import mongo, cursor


from bson.json_util import dumps
from bson.son import SON
from bson import json_util
import json

default_book_title = "untitled"
default_img_Url = "no-url"
# mongodb_database = kindle_metadata

class BookPreviewResource(Resource):
    
    def post(self):
        """Returns book information (lightweight)   
        Request Body: (asinArray) Array of string 
        Response Body: Array of json(asin,title,imUrl)"""

        # asinArray: array of string
        # Response Body: Array of json(asin, title, imURL?)
        parser = reqparse.RequestParser()
        parser.add_argument('page', type=int, location='args')
        parser.add_argument('count', type=int, location='args')
        args = parser.parse_args()
        json_request = request.get_json(force=True)
        _asinArray = json_request.get('asinArray')
        # create an array to host the json
        booksJSONArray = list()

        if (not args['count'] or not args['page']):
            # For each asin in asinArray, parse and request for the asin and its relevant info
            for asin in _asinArray:
                bookInfo = mongo.db.kindle_metadata.find_one({"asin": asin})
                book_asin = bookInfo.get('asin')
                book_title = bookInfo.get('title')
                book_imUrl = bookInfo.get('imUrl')  
                bookLW = {"asin": book_asin, "title": book_title, "imUrl":book_imUrl}
                booksJSONArray.append(bookLW)

        else:

            _limit = args['count']
            _offset = (args['page']-1) * args['count']
            
            cursor = mongo.db.kindle_metadata.find({}, {"asin" : 1}).skip(_offset)
            counter = 0
            for item in cursor:
                if item.get("asin") in _asinArray:
                    bookLW = {"asin":item.get("asin"), "title":item.get("title"), "imUrl":item.get("imUrl")}
                    booksJSONArray.append(bookLW)
                    counter += 1
                if counter == _limit:
                    break
               
        return {"message": "Book previews shown", "asinArray": str(_asinArray), "body": booksJSONArray}, 200
            


    

class BookCategoryResource(Resource):
    
    def post(self):

        """Returns books that have categories containing categories in categoryArray
        Request Body: (categoryArray) Array of String 
        Response Body: Array of json(asin, title, imUrl)"""
        #add the page count thingy
        parser = reqparse.RequestParser()
        parser.add_argument('page', type=int, location='args')
        parser.add_argument('count', type=int, location='args')
        args = parser.parse_args()
        json_request = request.get_json(force=True)
        _categoryArray = json_request.get('categoryArray')
        filteredArray = list()

        if (not args['count'] or not args['page']):
            cursor = mongo.db.kindle_metadata.find({})
            pageCountIsUsed = False
        else:
            _limit = args['count']
            _offset = (args['page']-1) * args['count']
            cursor = mongo.db.kindle_metadata.find({}).skip(_offset)
            pageCountIsUsed = True

        for item in cursor:
            counter = 0
            for category in _categoryArray:
                if category in list(item["categories"][0]):
                    counter += 1
            if counter == len(_categoryArray):
                filteredItem = {"asin":item.get("asin"), "title":item.get("title"), "imUrl":item.get("imUrl")}
                filteredArray.append(filteredItem)
            if pageCountIsUsed == True:
                newArray = list()
                #Limits items to 4 if page count is used
                for i in range(_limit):
                    newArray.append(filteredArray[i])
                filteredArray = newArray


        return {"message": "Books filtered based on categories", "categoryArray": str(_categoryArray), "body": filteredArray}, 200
                