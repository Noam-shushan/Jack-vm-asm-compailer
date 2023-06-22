from enum import Enum
import re

# Legal symbols of Jack
symbols = {'(', ')', '[', ']', '{', '}', ',', ';', '=', '.'}

# Legal operators of Jack
operators = {'+', '-', '*', '/', '&', '|', '~', '<', '>'}

# Legal reserved words of Jack
reserved_words = {'class', 'constructor', 'method', 'function', 'int', 'boolean',
                  'char', 'static', 'field', 'let', 'do', 'if', 'else', 'while',
                  'return', 'true', 'false', 'null', 'this', 'var', 'void'}


class TokenType(Enum):
    """
    Enum for token types in Jack:
    symbol, keyword, identifier, integerConstant, stringConstant
    """
    KEYWORD = "keyword"
    SYMBOL = "symbol"
    IDENTIFIER = "identifier"
    INT_CONST = "integerConstant"
    STRING_CONST = "stringConstant"


def parse_line_to_tokens(line):
    """
    :param line: line of jack code
    :return: list of tokens in line
    """
    symbols_reg = r'[\(\)\[\]\{\},;=\.]'
    operators_reg = r'[\+\-\*/&\|~<>]'
    reserved_words_reg = r'\b(?:class|constructor|method|function|int|boolean|char|static|field|let|do|if|else|while' \
                         r'|return|true|false|null|this|var)\b'
    str_reg = "\""
    regex_expression = rf'\s+|{str_reg}|{symbols_reg}|{operators_reg}|{reserved_words_reg}|"\w+"|\w+'
    tokens = filter(lambda x: x != " ", re.findall(regex_expression, line))
    is_in_string = False
    string = []
    for token in tokens:
        if is_in_string:
            if token == "\"":
                yield " ".join(string), TokenType.STRING_CONST
                string = []
                is_in_string = False
            else:
                string.append(token)
        elif token == "\"":
            is_in_string = True
        elif token in symbols:
            yield token, TokenType.SYMBOL
        elif token in reserved_words:
            yield token, TokenType.KEYWORD
        elif token.isdigit():
            yield token, TokenType.INT_CONST
        elif token in operators:
            if token == '<':
                yield '&lt;', TokenType.SYMBOL
            elif token == '>':
                yield '&gt;', TokenType.SYMBOL
            elif token == '&':
                yield '&amp;', TokenType.SYMBOL
            else:
                yield token, TokenType.SYMBOL
        elif token.isspace():
            continue
        else:
            yield token, TokenType.IDENTIFIER


def get_xml_token(token, token_type):
    """

    :param token: token value
    :param token_type: token type
    :return: xml representation of token
    """
    return f'<{token_type.value}>{token}</{token_type.value}>\n'


def generate_xml_file(filename):
    """
    :param filename: filename of jack file
    :return: xml representation of jack file
    """
    xml_filename = filename.split('.')[0] + "T" + '.xml'
    with open(xml_filename, "w") as xml_file:
        xml_file.write("<tokens>\n")
        for line in get_jack_file_lines(filename):
            for token in parse_line_to_tokens(line):
                t, tt = token
                xml_file.write("\t" + get_xml_token(t, tt))
        xml_file.write("</tokens>\n")


def get_jack_file_lines(filename):
    """
    :param filename: filename of jack file
    :return: code lines only (no comments) in file as a generator
    """
    start_block_token = '/**'
    end_block_token = '*/'
    with open(filename, 'r') as jack_file:
        is_in_block_comment = False
        for line in jack_file:
            # watch for block comments
            if is_in_block_comment:
                if end_block_token in line:
                    is_in_block_comment = False
                if end_block_token not in line:
                    is_in_block_comment = False
                continue
            if start_block_token in line:
                is_in_block_comment = True
                continue

            # remove inline comments
            line = line.split('//')[0]

            # prevent empty lines
            if not line.strip():
                continue

            # remove leading and trailing whitespace and return line with single space between tokens
            tokens = filter(lambda x: x != '', line.strip().split())
            yield ' '.join(tokens)
